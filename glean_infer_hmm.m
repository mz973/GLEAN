function hmm = glean_infer_hmm(data,options,T)
% Infers an hidden Markov model (HMM) with particular options.
%
% hmm = GLEAN_INFER_HMM(data,options)
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

% Check data dimensions
if size(data,1) < size(data,2)
    data = transpose(data);
end

if nargin < 3 || isempty(T)
    T = size(data,1);
end

% Ensure that some minimum defaults are set
if ~isfield(options,'K');options.K = 8;end
if ~isfield(options,'order');options.order = 0;end
if ~isfield(options,'Ninits');options.Ninits = 5;end
if ~isfield(options,'zeromean');options.zeromean = 0;end
if ~isfield(options,'inittype');options.inittype = 'GMM';end
if ~isfield(options,'initcyc');options.initcyc = 100;end
if ~isfield(options,'initrep');options.initrep = 5;end

% Run HMM inference with multiple initialisations
FrEn = Inf;
for i = 1:options.Ninits

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

