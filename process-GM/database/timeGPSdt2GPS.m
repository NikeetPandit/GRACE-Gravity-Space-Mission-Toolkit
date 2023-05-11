function [timeGPS] = timeGPSdt2GPS(timeGPSdt)
% timeGPSdt2GPS parses in an epoch (OR an array of epochs) in GPS time of
%   type datetime and converts to a GPS epoch of type double using the
%   GRACE space mission convention. 
%
% Inputs:
%   (1) timeGPS:   Type datetime. Size [nx1].
%
% Outputs:
%   (1) timeGPS:   Type double. Size [nx1].
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
if class(timeGPSdt) ~= "datetime"
    error("Class of inputted data must be of type datetime."); 
end

%--- GPS seconds reference epoch is continuous seconds past 01-Jan-2000 12:00:00 GPS
refepoch = datetime(2000, 1, 1, 12, 0, 0); 

%--- Converting GPS datetime object to ref. epoch
timeGPS = convertTo(timeGPSdt, 'epochtime', 'Epoch', refepoch); 

end