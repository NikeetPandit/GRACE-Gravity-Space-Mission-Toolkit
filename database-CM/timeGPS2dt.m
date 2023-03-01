function timeGPSdt = timeGPS2dt(timeGPS)
% TIMEGPS2dt accepts an epoch (OR an array of epochs) in GPS time
%   of type double and coverts to GPS datetime object(s) using the GRACE
%   space mission convention.
%
% Inputs:
%   (1) timeGPS:   Type double. Size [nx1].
%
% Outputs:
%   (1) timeGPSdt: Type datetime. Size [nx1] 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
if ~isequal(class(timeGPS), "double")
    error("Class of inputted data must be of type double."); 
end

%--- GPS seconds reference epoch is continuous seconds past 01-Jan-2000 12:00:00 GPS
refepoch = datetime(2000, 1, 1, 12, 0, 0, 0); 

%--- Converting to GPS datetime object without adding leap seconds
timeGPSdt = datetime(timeGPS, 'ConvertFrom', 'epochtime', 'Epoch', refepoch); 

end