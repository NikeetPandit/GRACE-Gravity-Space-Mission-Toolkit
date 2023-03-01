function M = avg_sample_rate(time)
% avg_sample_rate determines average sampling rate of an array. 
%
%   Inputs:
%   (1) time, 1-D [nx1] time array
%
%   Outputs:
%   (1)  M, sampling rate
%
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[~, m] = size(time); 
if ~isequal(m, 1)
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Determine avg sample rate
M = 1./round(mean(diff(time)), 2); 

end