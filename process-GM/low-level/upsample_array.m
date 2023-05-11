function arrayOut = upsample_array(arrayIn, N)
% upsample_array upsamples an array linearly by an integer factor N. 
%   
%   If parsed time array is irregularly sampled, an output array which is
%   reguarly sampled to N will be returned, regularized by linear
%   interpolation. 
% 
%   The motivation of this routine is that is used to upsample 1Hz linear
%   acceleration time array to 10Hz (but works for any value), so
%   interpolation can be performed thereafter, evaluated for the query
%   points that are determined by this function. 
%
%   Inputs:
%   (1) arrayIn:  1-D array to be upsampled. Size [nx1]. 
%   (2) N:        integer factor to upsampled. 
%
%   Outputs:
%   (1) arrayOut: 1-D array at sampling rate of N. Size [nx1]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[~, m] = size(arrayIn); 
if ~isequal(m, 1)
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Debug check 
if ~isequal(round(N), N)
    error("N must be an integer factor"); 
end

%--- Upsampling 1-D array
xp = 0:length(arrayIn) - 1; targets = 0: 1/N: length(arrayIn) - 1;
arrayOut = interp1(xp, arrayIn, targets); 

end