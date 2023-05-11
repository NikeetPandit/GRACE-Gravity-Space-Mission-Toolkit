function timeGPSdt = timeGPS2dt_goce(timeGPS)
% timeGPS2dt accepts an epoch (OR an array of epochs) in GPS time
%   of type double and coverts to GPS datetime object(s) using the GOCE
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

%--- GPS seconds reference epoch is continuous seconds past 06-Jan-1980 0:00
refepoch = datetime(1980, 1, 6); 

%--- Converting to GPS datetime object without adding leap seconds
timeGPSdt = datetime(timeGPS, 'ConvertFrom', 'epochtime', 'Epoch', refepoch); 

end