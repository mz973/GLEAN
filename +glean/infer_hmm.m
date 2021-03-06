function hmm = infer_hmm(data,options)
% Infers an hidden Markov model (HMM) with particular options.
%
% hmm = glean.infer_hmm(data,options)
%
% REQUIRED INPUTS:
%   data     - observations (channels x samples)
%   options  - structure with the training options - see documentation in
%              HMM-MAR toolbox
%
% OUTPUTS:
%   hmm      - estimated HMM model
%
% Adam Baker 2015

Ninits = options.Ninits;
options = rmfield(options,'Ninits');

% Check data dimensions
if size(data,1) < size(data,2)
    data = transpose(data);
end

T = size(data,1);

% Run HMM inference with multiple initialisations
FrEn = Inf;
for i = 1:Ninits
    options.inittype = 'EM';
    options.initcyc = 100;
    options.initrep = 5;
    
    [hmm_new, Gamma, ~, vpath, ~, ~, fehist] = hmmmar(data,T,options);
    % keep inference if Free Energy is lower
    if fehist(end) < FrEn
        hmm = hmm_new;
        hmm.statepath = vpath;
        hmm.train.Gamma=Gamma;
        FrEn = fehist(end);
    end
end 
hmm.FrEn = fehist(end);
hmm.FrEn_hist = fehist;    

% Set sampling rate
if isfield(options,'Fs')
    hmm.fsample = options.Fs;
else
    hmm.fsample = [];
end

    
% Output covariance matrices for MVN case
if options.order == 0
    for k = 1:hmm.K
        hmm.state(k).Cov = hmm.state(k).Omega.Gam_rate./hmm.state(k).Omega.Gam_shape;
    end
end

