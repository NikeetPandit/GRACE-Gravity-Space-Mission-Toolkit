function [ACC, POS_IRF, SCA1B, ACC_DateEpochs] = compile_daily_inputs(inputs)
% compile_date lo retreive, compile, and processes data as necessary
%   for GRACE gradiometery, and as specified in inputs. 
%
%   Inputs:
%   (1) inputs: Type structure. See handle_inputs function for convention. 
%
%   Outputs:
%   (1) ACC: Accelerometer data. 
%   (2) POS_IRF: Position data in IRF interpolated to ACC time tags
%   (3) SCA1B: SCA1B data interpolated to ACC time tags
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Determing which accelerometer product must be used based on inputs
ACCprod = process_inputs(inputs); 

%--- Read in approriate acceleration data based on inputs and pre-process 

try
    [ACC, ind_ACC] = read_ACC(inputs.GRACE_ID, inputs.Processing_Day, ...
        inputs.Path1A, inputs.Path1B, ACCprod, 'pad', 3); % See fun. for more info
    
        %--- Isolating GPS time stamps for Date without padding
        ACC_DateEpochs = [ACC(ind_ACC(1),1), ACC(ind_ACC(2), 1)];

%--- Debug check 1 | Triggered when data file is empty
catch
    error(cat(2, 'No file for ACC data for selected ID. Skipping Day... ', datestr(inputs.Processing_Day)));
    
end

%--- Debug check 2 | Triggered when no measurements available in file 
if isempty(ACC)
    error(cat(2, 'No ACC data for selected loaded file. Skipping Day... ', datestr(inputs.Processing_Day))); 
  
end

%--- Performing gaussian zero-phase band-pass filtering if selected
if ~isempty(inputs.Filter_Type)
    ACC(:,2:end) = gaussian_FIR(ACC(:,1), ACC(:,2:end), inputs.Filter_Type, ...
        inputs.Filter_Cut_Offs, inputs.Filter_Order);
end

%--- Upsample ACC data if requested
if isequal(inputs.Interpolate_ACC,1) && strcmpi(ACCprod, 'ACT1A') == 0
    try
    %--- Interpolating ACC data to 10Hz, low-pass filter before-hand
    ACC(:,2:end) = gaussian_FIR(ACC(:,1), ACC(:,2:end), 'lp', 10^-1, 10);
    ACC = ACC_upsample(ACC);
    
    %--- Triggered when major extrpolation in upsampling procedure
    catch
        error(cat(2, 'Major gaps in ACC data for selected ID. Skipping Day... ', datestr(inputs.Processing_Day))); 

    end
end

%------------------------------------------------------------------------------------------------------------------
%--- Read in IRF SST data and interpolate to time-tags of accelerometer data

POS_IRF = read_GNI1B_IRF(inputs.GRACE_ID, inputs.Processing_Day, inputs.Path1B, 'pad', 7); % padding to prevent extrpolation 

% -- Interpolating ECI SST data to ACC time stamps w/o extrapolation
POS_IRF = interp_spline(POS_IRF, ACC(:,1)); 

%------------------------------------------------------------------------------------------------------------------
%--- Read in SCA1B data and interpolate to time-tags of accelerometer data

%--- Read in SCA1B and flip to make continuous in time
try
    [SCA1B, Flag] = flip_quats(read_SCA1B(inputs.GRACE_ID, inputs.Processing_Day, inputs.Path1B, 'pad', 20)); % See fun for more info

catch
    error(cat(2, 'Skipping...',  datestr(inputs.Processing_Day)))
end

%--- Check flag to see if any susupected errors in flip_quats function
if isequal(Flag, 1)
    error(cat(2, ['There are likely discontinuties in SCA1B that...' ...
        ' have not been corrected. Skipping'], datestr(timeGPS2dt(SCA1B(1,1)))))
end

%--- Interpolate SCA1B data to ACC time tags
SCA1B = interp_spline(SCA1B, ACC(:,1)); 

%--- Check time tags of data are associated correctly and associate if not
try
    [ACC, POS_IRF, SCA1B] = check_timetags(ACC, POS_IRF, SCA1B); % See in-line funciton

catch
    error(cat(2, 'Large data gaps. Skipping Day... ', datestr(inputs.Processing_Day)));

end
end

%--- Check to see if time tags of input data are associated together and
function [ACC, POS_IRF, SCA1B] = check_timetags(ACC, POS_IRF, SCA1B)

%--- Ensuring all data is associated correctly 
if ~isequal(ACC(:,1), POS_IRF(:,1), SCA1B(:,1))
    
    %--- Interpolating without extrapolation if not 
    ACC = interp_spline(ACC, POS_IRF(:,1)); % Occurs b/c of missing data
    ACC = interp_spline(ACC, SCA1B(:,1)); 
    POS_IRF = interp_spline(POS_IRF, ACC(:,1)); 
    POS_IRF = interp_spline(POS_IRF, SCA1B(:,1)); 
    SCA1B = interp_spline(SCA1B, ACC(:,1)); 
    SCA1B = interp_spline(SCA1B, POS_IRF(:,1)); 

    %--- If still not associated correctly
    if ~isequal(ACC(:,1), POS_IRF(:,1), SCA1B(:,1))
        error("Could not associate data correctly."); 
    end
    
end


end
