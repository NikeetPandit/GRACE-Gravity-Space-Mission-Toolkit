function output = compute_GGOMO(inputs, processing_day)
%% Preliminary 
%------------------------------------------------------------------------------------------------------------------
%--- Setting paths, variables, etc.
switch nargin 
    case 1
        if      isempty(inputs.Processing_Day) && isesmpty(inputs.Compute_Start_Date)
            error("Must specify processing day."); 

        elseif  isempty(inputs.Processing_Day) && ~isempty(inputs.Compute_Start_Date)
            inputs(1).Processing_Day = inputs.Compute_Start_Date; 
        end
        
    case 2
        inputs(1).Processing_Day = processing_day; % If processing day is explicitly parsed

    otherwise
    error("Incorrect number of inputs parsed."); 
end

%--- Setting paths
disp(cat(2, 'Processing Day... ', datestr(inputs.Processing_Day))); warning('on'); 

%--- Setting current working directory
cd(inputs.Working_Directory); 

%--- Set 1B path based ond date
inputs =  setGRACEfolder(inputs); 


%% Compile and Process Inputs
%
%------------------------------------------------------------------------------------------------------------------

%--- retreive, compile, and processes data as necessary for GRACE gradiometery, and as specified by user-inputs
[ACC, POS_IRF, SCA1B, ACC_DateEpochs] =  compile_daily_inputs(inputs);


%% Apply "Gradiometer System"
%
%------------------------------------------------------------------------------------------------------------------
%--- Find the min approach between the "two" spacecraft
shift = inputs.GMshift* round(avg_sample_rate(ACC(:,1))); 
if isempty(shift)
    shift = 1; 
end
%--- Assign "leading" spacecraft measurements
ACC_A = ACC(shift+1:end, :); POS_IRF_A = POS_IRF(shift+1:end, :); SCA1B_A = SCA1B(shift+1:end,:); 

%--- Assign "trailing" spacecraft measurements
ACC_B = ACC(shift:end-shift,:); POS_IRF_B = POS_IRF(shift:end-shift,:); SCA1B_B = SCA1B(shift:end-shift,:); 

%------------------------------------------------------------------------------------------------------------------

%--- Rotate all time-shifted trailing and leading measurements to leading SRF 
[ACC_A, ACC_B, POS_A_SRF, POS_B_SRF] = transform2leadSRF(ACC_A, ACC_B, SCA1B_A, SCA1B_B, POS_IRF_A, POS_IRF_B);

%% Format Daily Outputs
%
%------------------------------------------------------------------------------------------------------------------
%--- Compiling output
output = compile_daily_outputs(inputs, ACC_A, ACC_B, POS_A_SRF, POS_B_SRF, ACC_DateEpochs); 

%--- Changing directory back to working directory
cd(inputs.Working_Directory);  


end

