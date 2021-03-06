function D = normalise(S)
% Performs normalisation of MEEG data.
%
% D = glean.normalise(S)
%
% REQUIRED INPUTS:
%   S.D              - Name of the SPM12 MEEG object
%   S.normalisation  - Type of normalisation to apply
%                      ['none','voxel','global']
%
% OUTPUTS:
%   D         - Normalised SPM12 MEEG data 
%
% Adam Baker 2015


D = spm_eeg_load(S.D);

% TODO: Gotta sort this out for trialwise data
trl = 1;

nFreq = D.nfrequencies;
if isempty(nFreq)
    nFreq = 1;
end

% Maybe block this:
if isequal(D.transformtype,'TF')
    means = mean(D(:,:,:,:),3);
    stdev = std(D(:,:,:,:),[],3);
else
    means = mean(D(:,:,:),2);
    stdev = std(D(:,:,:),[],2);
end
            
            
for f = 1:nFreq
    
    if isequal(D.transformtype,'TF')
        
        D(:,f,:,trl) = D(:,f,:,trl) - repmat(means(:,f),1,1,D.nsamples);
        switch(S.normalisation)
            case 'voxel'
                D(:,f,:,trl) = D(:,f,:,trl) ./ repmat(stdev(:,f),1,1,D.nsamples);
            case 'global'
                D(:,f,:,trl) = D(:,f,:,trl) ./ repmat(mean(stdev(:,f)),D.nchannels,1,D.nsamples);
        end
        
    else
        
        D(:,:,trl) = D(:,:,trl) - repmat(means,1,D.nsamples);
        switch(S.normalisation)
            case 'voxel'
                D(:,f,:,trl) = D(:,:,trl) ./ repmat(stdev,1,D.nsamples);
            case 'global'
                D(:,f,:,trl) = D(:,:,trl) ./ repmat(mean(stdev),D.nchannels,D.nsamples);
        end
        
    end
    
end

D.save;


end