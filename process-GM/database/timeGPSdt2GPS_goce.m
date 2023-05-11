function [timeGPS] = timeGPSdt2GPS_goce(timeGPSdt)
% timeGPSdt2GPS parses in an epoch (OR an array of epochs) in GPS time of
%   type datetime and converts to a GPS epoch of type double using the
%   GOCE space mission convention. 
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

%--- GPS seconds reference epoch is continuous seconds past 06-Jan-1980 0:00
refepoch = datetime(1980, 1, 6); 

%--- Converting GPS datetime object to ref. epoch
timeGPS = convertTo(timeGPSdt, 'epochtime', 'Epoch', refepoch); 

end