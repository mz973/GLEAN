function glean_envelope(GLEAN)
% Runs the envelope stage of GLEAN.
%
% GLEAN_ENVELOPE(GLEAN)
%
% Adam Baker 2015


pretty_string('RUNNING ENVELOPE STAGE')

for session = 1:numel(GLEAN.data)
    
    
    % Check if envelope file exists and whether or not to overwrite
    file_exists = exist(GLEAN.envelope.data{session},'file') == 2;
    overwrite   = GLEAN.envelope.settings.overwrite == 1;
    if file_exists
        if overwrite
            msg = ['Overwriting existing envelope file: \n' GLEAN.envelope.data{session} '\n'];
            run_stage = true;
        else
            msg = ['Using existing envelope file: \n' GLEAN.envelope.data{session} '\n'];
            run_stage = false;
        end
    else
        msg = ['Creating new envelope file: \n' GLEAN.envelope.data{session} '\n'];
        run_stage = true;
    end
    fprintf(msg);
    
    
    if run_stage
                
        % Make a temporary filename to copy raw data to
        [~,tempdata] = fileparts(tempname);
        tempdata = fullfile(fileparts(GLEAN.envelope.data{session}),tempdata);
        
        % Copy data to temporary filename
        [p,f] = fileparts(GLEAN.data{session});
        for ext = {'.mat','.dat'}
            system(['cp ' fullfile(p,f) char(ext) ' ' tempdata char(ext)]);
        end
                
        % Compute envelopes
        S               = [];
        S.D             = tempdata;
        S.fsample_new   = GLEAN.envelope.settings.fsample;
        S.logtrans      = GLEAN.envelope.settings.log;
        if isfield(GLEAN.envelope.settings,'freqbands')
            S.freqbands = GLEAN.envelope.settings.freqbands;
        else
            S.freqbands = [];
        end
        S.demean    = 0;
        S.prefix    = '';
        D = glean_hilbenv(S);
        
        % Rename file
        move(D,GLEAN.envelope.data{session});
        
        % Tidy up
        system(['rm ',tempdata,'.*at']);
       
    end

end


