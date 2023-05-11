function M = avg_sample_rate(time)
% avg_sample_rate determines average sampling rate of an array. 
%
%   Inputs:
%   (1) time: 1-D  time array. Size [nx1]/
%
%   Outputs:
%   (1)  M: sampling rate. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[~, m] = size(time); 
if ~isequal(m, 1)
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Determine avg sample rate
M = 1./round(mean(diff(time)), 1); 

%--- Rounding ..
if M > 0.75 
    M = ceil(M); 
end
end