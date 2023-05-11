function DATAxyz_Interp = interp_spline(DATAxyz, TimeArray)
% interp_spline is a decorator for MATLAB's interp1 function to 
%  improve code readability. No extrapolated data is returned. 
%
%  The motivation for not returning extrapolated data is to not include
%  any unreliable data in the processing of gravity gradient solutions.
%
%  To always have valid interpolation, pad your data when reading them in. 
%  See any of the read_ functions for more information. 
%
%   Inputs:
%   (1) DATAxyz: [time, X, Y, Z]. Size [nx4]. 
%   (2) TimeArray: 1-D array denoting the query points for interpolation.
%
%   Outputs:
%   (1) DATAxyz_Interp: [time, X, Y, Z]. Size [nx4]
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check
[~, m] = size(DATAxyz); [~, m1] = size(TimeArray);
if ~isequal(m, 4) && ~isequal(m, 5) || ~isequal(m1, 1)
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Interpolating DATAxyz to time array and adding NaN where extrapolation occurs
DATAxyz_Interp = [TimeArray interp1(DATAxyz(:,1), DATAxyz(:,2:end), TimeArray, 'spline', NaN)]; 

%--- Removing NaN from interpolated array
DATAxyz_Interp = rmmissing(DATAxyz_Interp); 

end


