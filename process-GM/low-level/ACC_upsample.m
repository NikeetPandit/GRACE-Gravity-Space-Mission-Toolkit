function [ACC_up] = ACC_upsample(ACC)
% ACC_upsample interpolates accelerometer data given in 1Hz to 10Hz via splines
%   Uses MATLAB's interp1 function. 
%
%   Inputs:
%   (1) ACC, [nx4] input matrix interpreted as [time, X, Y, Z] in 1Hz
%
%   Outputs:
%   (1)  ACC_up, [nx4] matrix interpreted as [time, X, Y, Z]  in 10Hz
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check
M = avg_sample_rate(ACC(:,1)); 
if ~isequal(M, 1)
    error("Parsed in acceleromter data is not 1Hz. Investigate"); 
end

%--- Debug check
[~, m] = size(ACC); 
if ~isequal(m, 4)
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Upsample time vector to 10Hz 
timeA_up = transpose(upsample_array(ACC(:,1), 10)); % see upsample_array fun for details

%--- Interpolate acceleromter data to 10Hz via splines 
ACC_up = [timeA_up interp1(ACC(:,1), ACC(:,2:end), timeA_up, 'spline')];

end