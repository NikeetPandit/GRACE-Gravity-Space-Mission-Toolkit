function reshapeOut = pagewise_reshape(shapeIn)
% pagewise_shape parses in an [3x1xn] array and reshapes it to [nx3]. 
%   See to_pagewise_shape function for motiviation. 
%
%   Inputs:
%   (1) shapeIn: Size [3x1xn]. 
%
%   Outputs:
%   (1) reshapeOut: Interpreted as [X, Y, Z]. Size [nx3]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[i, j, ~] = size(shapeIn);
if numel(size(shapeIn)) ~= 3
    error("Dimensions of input data not correct. See documentation"); 
elseif i ~= 3
    error("Dimensions of input data not correct. See documentation"); 
elseif j~= 1
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Reshaping
reshapeOut = reshape(shapeIn, 3, [])';

end