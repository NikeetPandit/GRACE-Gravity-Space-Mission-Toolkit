function ACCinSRF_GPS = get_ACCinSRFfromGPS(ID, Date, PathData)
% Function derives accelerations in SRF from GPS positions.
%
%   Function returns the ACCinSRF from GPS for the same time-tags that
%   would be returned if the POD positions were read in from GNV1B or GNI1B
%   data product, for specified ID and date. 
%
%   Uses MATLAB sgolayfilt function. 
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product.
%
%   Outputs:
%   (1) ACCinSRF_GPS: [timeGPS, ACC_X, ACC_Y, ACC_Z]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%------------------------------------------------------------------------------------------------------------------

%--- Read in GRACE position in IRF
[POS, ind] = read_GNI1B_IRF(ID, Date, PathData, 'pad', 1);

%--- Find time-stamp associated to unpadded data
time_stamp = [POS(ind(1), 1), POS(ind(2), 1)]; 

%--- Read in SCA1B data, make continuous for valid interpolation
SCA1B = flip_SCA1B(read_SCA1B(ID, Date, PathData, 'pad', 3));

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
index = [find(ACCinSRF_GPS(:,1) == time_stamp(1)) find(ACCinSRF_GPS(:,1) == time_stamp(2))]; 

%--- Isolate returned output to time-frame of GNI1B data for given date, ID
ACCinSRF_GPS = ACCinSRF_GPS(index(1):index(2),:); 

end