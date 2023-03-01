function [timeUTCdt, n1] = timeGPS2UTC(timeGPS)
% TIMEGPS2UTC accepts an epoch (OR an array of epochs) in GPS time
%   of type double and coverts to UTC datetime object(s) assuming the GRACE
%   space mission convention. 
%
% Inputs:
%   (1) timeGPS:   Type double. Size [nx1].
%
% Outputs: 
%   (1) timeUTCdt: Type datetime. Size [nx1]. 
%   (2) n1: Leap Seconds since 01-Jan-1972 00:00:00 UTC. Type double. Size [nx1] 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
if ~isequal(class(timeGPS), "double")
    error("Class of inputted data must be of type double."); 
end

%--- GPS seconds ref epoch is continuous seconds past 01-Jan-2000 11:59:47 UTC
refepoch = datetime(2000, 1, 1, 11, 59, 47) - seconds(32); % Subtract total amount of leap seconds since 1 Jan 1999

%--- Adding the leap seconds elapsed since refepoch
timeUTCdt = datetime(timeGPS, 'TimeZone', 'UTCLeapSeconds', 'ConvertFrom', 'epochtime', 'Epoch', refepoch); 
timeUTCdt.TimeZone = 'UTC'; 

%--- Assigning dummy time-zone to GPS time to determine leap seconds 
timeGPSdt = timeGPS2dt(timeGPS); timeGPSdt.TimeZone = 'UTC';

%--- Leap Seconds = GPS time - UTC time 
n1 = seconds(timeGPSdt - timeUTCdt) + 19; % Leap Seconds since 01-Jan-1972 00:00:00 UTC

end