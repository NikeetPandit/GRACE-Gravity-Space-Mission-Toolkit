function reshapeOut = to_pagewise_shape(shapeIn)
% TO_PAGEWISE_SHAPE accepts an array and reshapes it along a third
%   dimension for pagewise multiplication. 
%
%   The motivation for this routine is computational efficiency since the
%   code can be vectorized when doing for ex., many coordinate
%   transformations. See https://www.mathworks.com/help/matlab/ref/pagemtimes.html
%   See ITRFtoIRF function. 
%
%   Inputs:
%   (1) shapeIn: Interpreted as [X, Y, Z]. Size [nx3]. 
%
%   Outputs:
%   (1) reshapeOut: Size [3x1xn]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[~, n] = size(shapeIn);
if numel(size(shapeIn)) ~= 2
    error("Dimensions of input data not correct. See documentation"); 
elseif n ~= 3
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Reshaping along third dimension 
reshapeOut = [reshape(shapeIn(:,1), 1, 1, []); reshape(shapeIn(:,2), 1, 1, []); reshape(shapeIn(:,3), 1, 1, [])];

end