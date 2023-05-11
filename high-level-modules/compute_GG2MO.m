function output = compute_GG2MO(inputs, processing_day)
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

%--- Determine if date corresponds to GRACE or GRACE-FO
mission = det_GRACEmission(inputs.Processing_Day); 

if      isequal(mission, 'GRACE')
    ID = ["A", "B"]; 
    
elseif  isequal(mission, 'GRACE_FO') 
    ID = ["C", "D"]; 

end
%% Compile and Process Inputs
%
%------------------------------------------------------------------------------------------------------------------
%--- retreive, compile, and processes data as necessary for GRACE gradiometery, and as specified by user-inputs

%--- Compiling data for GRACE B or D
inputs.GRACE_ID = ID(1);
[ACC_A, POS_IRF_A, SCA1B_A, ACC_DateEpochsA] = compile_daily_inputs(inputs); 

%--- Compiling data for GRACE B or D
inputs.GRACE_ID = ID(2); 
[ACC_B, POS_IRF_B, SCA1B_B, ACC_DateEpochsB] = compile_daily_inputs(inputs); 
    
N = min([length(ACC_A), length(ACC_B)], [], 2); 
%--- See if two time-stamps same index leading and trailing ACC measurements are offeset by more than 50 seconds
if any(ACC_A(1:N,1) - ACC_B(1:N,1) > 50 )
    output = []; 
    disp(cat(2, ['Missing lots of trailing or... ' ...
        'leading accelerometer data. Skipping Day... '], datestr(Date))); 
    return; 
end

%------------------------------------------------------------------------------------------------------------------
%--- Determing leading and trailing spacecraft along flight motion 
ID_A = find_lead_SC(POS_IRF_A, SCA1B_A); 

%--- If GRACE "A" or GRACE-FO "C" is not leading | switch variable assignment for software interpretation

if ~isequal(ID(1), ID_A)

    %--- Assigning a temporary cell variable 
    temp = {ACC_A, POS_IRF_A, SCA1B_A, ACC_DateEpochsA}; 

    %--- Assign "_B" variables to "_A" as to denote leading spacecraft
    ACC_A = ACC_B; POS_IRF_A = POS_IRF_B; SCA1B_A = SCA1B_B;
    ACC_DateEpochsA = ACC_DateEpochsB;

    %--- Assign "_A" variables to "_B" to denote trailing spacecraft
    ACC_B = temp{1}; POS_IRF_B = temp{2}; SCA1B_B = temp{3}; 
    ACC_DateEpochsB = temp{4}; clear temp 
 
end

ACC_DateEpoch = [ACC_DateEpochsB(1) ACC_DateEpochsA(2)]; 

%% Apply "Gradiometer System"
%
%------------------------------------------------------------------------------------------------------------------
%--- Find the min approach between the two spacecraft using algorithms specified by user

%--- Place empty shift to find
if  isempty(inputs.GMshift)
%--- Find the approach
    [~, shift] = minDistSRF_xyz(POS_IRF_A,  POS_IRF_B, SCA1B_A, [1500, 0, 1000]); 

    [ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B] ...
        = set_lag(ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B, shift); 

elseif strcmpi(inputs.GMshift, 'norm')

%--- Place dummy number to evaluate to norm
[ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B]...
    = min_norm(ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B);

else
    error("GM shift value must be set to empty or norm.")

end

%------------------------------------------------------------------------------------------------------------------

%--- Rotate all time-shifted trailing and leading measurements to leading SRF 
[ACC_A, ACC_B, POS_A_SRF, POS_B_SRF] = transform2leadSRF(ACC_A, ACC_B, SCA1B_A, SCA1B_B, POS_IRF_A, POS_IRF_B);


%% Format Daily Outputs
%
%------------------------------------------------------------------------------------------------------------------
%--- Compiling processed daily outputs
output = compile_daily_outputs(inputs, ACC_A, ACC_B, POS_A_SRF, POS_B_SRF, ACC_DateEpoch); 

%--- Changing directory back to working directory
cd(inputs.Working_Directory); 
end
