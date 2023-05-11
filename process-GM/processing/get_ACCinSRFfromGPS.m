function [ACCinSRF_GPS, ind] = get_ACCinSRFfromGPS(ID, Date, Path, varargin)
% Function derives accelerations in SRF from GPS positions.
%
%   Function returns the ACCinSRF from GPS for the same time-tags that
%   would be returned if the POD positions were read in from GNV1B or GNI1B
%   data product, for specified ID and date, with optional padding. 
%
%   Uses MATLAB sgolayfilt function. 
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product.
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%   Padding must be less than 20 hours.
%
%   Outputs:
%   (1) ACCinSRF_GPS: [timeGPS, ACC_X, ACC_Y, ACC_Z]. 
%   (2) ind:  [Start Index, End Index] for data of Date requested in output (1). Size [1x2].
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%------------------------------------------------------------------------------------------------------------------

%--- Reading variable-input
pad = find(strcmpi(varargin, 'pad'), 1);

%--- Assigning some small padding even if no padding is selected
if isempty(pad) 
    pad_val = 1; 
else
    pad_val = varargin{pad+1}; 
    if pad_val == 0
        pad = []; pad_val = 1; 
    end
end

%--- Input debug check
if pad_val > 20
    error("Requested padding is too much. See documentation."); 
end

%--- Read in GRACE position in IRF
[POS, ind] = read_GNI1B_IRF(ID, Date, Path, 'pad', pad_val);

%--- Interpolate postion data to 1Hz
if ID == "A" || ID == "B"
    Fs = avg_sample_rate(POS(:,1));
    if Fs ~= 0.2
        error("Large gaps in POD Data"); 
    end
    %--- Read in ACC data in SRF to interpolate POS data to 
    [ACC, ind] = read_ACC1B(ID, Date, Path, 'pad', pad_val + 2);

    %--- Smooth 0.2Hz position data before interpolating 
    POS(:,2:end) = gaussian_FIR(Fs, POS(:,2:end), 'lp', 0.1, 10); 

    %--- Interpolate position data to accelerometer time stamps
    POS = interp_spline(POS, ACC(:,1)); 

    time_stamp = [ACC(ind(1), 1), ACC(ind(2), 1)]; % already in 1Hz
    clear ACC

else
        
%--- Find time-stamp associated to unpadded data
    time_stamp = [POS(ind(1), 1), POS(ind(2), 1)]; % already in 1Hz

end

%--- Read in SCA1B data, make continuous for valid interpolation
SCA1B = flip_quats(read_SCA1B(ID, Date, Path, 'pad', 23));

%--- Interpolate SCA1B to POS data time array
SCA1B = interp_spline(SCA1B, POS(:,1));  

%--- Fit 4th order polynomial to positions with data span of 5 elements
POS(:,2:end) = sgolayfilt(POS(:,2:end), 4, 5); % chosen b/c GOCE derives vel from pos using this order/span                                            

%--- Take derivative to get velocity in IRF
VEL = [POS(2:end, 1) diff(POS(:,2:end),1)./diff(POS(:,1), 1)]; 

%--- Fit 4th order polynomial to positions with data span of 5 elements
VEL(:,2:end) = sgolayfilt(VEL(:,2:end), 4, 5);

%--- Take derivative to get acceleration in IRF
ACC = [POS(3:end,1) diff(VEL(:,2:end), 1)./diff(VEL(:,1), 1)];

%--- Transform acceleration in IRF to SRF of GRACE ID
ACCinSRF_GPS = IRFtoSRF(ACC, SCA1B(3:end, :)); 

%--- Find index associated to un-padded data
ind = [find(ACCinSRF_GPS(:,1) == time_stamp(1)) find(ACCinSRF_GPS(:,1) == time_stamp(2))]; 

%--- Isolate returned output to time-frame of GNI1B data if no padding selected
if isempty(pad)
    ACCinSRF_GPS = ACCinSRF_GPS(ind(1):ind(2),:); 
    ind = []; 
end

end