function DATAxyzIRF = ITRFtoIRF(DATAxyzITRF, varargin) 
% ITRFtoIRF is a function decorator for MATLAB's dcmeci2ecef to rotate a
%   vector to IRF from ITRF.
% 
%   See: https://www.mathworks.com/help/aerotbx/ug/dcmeci2ecef.html
% 
%   The purpose of the decorator is to provide abstraction to calculation
%   and inclusion of higher-order terms in dcmeci2ecef function, and to
%   include performance improvements. Uses IAU 2000/2006 resolution to 
%   comply with the IERS-2010 recommendations. 
%   
%   Uses: mjuliandate, polarMotion, deltaCIP, deltaUT1 MATLAB function's. 
%
%   Inputs:
%   (1) DATAxyzITRF: [timeGPS, POS_X, POS_Y, POS_Z]. Size [nx4]. 
%   timeGPS is interpreted as a GPS time epoch, using the GRACE and GRACE-FO
%   convention for GPS time. 
%
%   Optional: 'none'. Input to specify the use of NO higher-order terms in
%   position vector transformation. 
% 
%   Outputs:
%   (1)  DATAxyzIRF: [timeGPS, POS_X, POS_Y, POS_Z]. Size [nx4]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%%
%   EXTRA NOTES:
%
%   When the higher-order terms are omitted, there is an error up to 100m
%   against JPL's transformations. When they are included, there is an error 
%   at most 0.1m against JPL. 
%
%   This test was made by comparing GNV1B_ITRF data products by JPL for GRACE-FO
%   and transforming it to IRF, using ITRFtoIRF, and comparing this against
%   JPL's GNI1B data product, which provides the coordinates already in the
%   IRF frame. 
%
%   Using additional terms comes at cost of computational complexity. To
%   improve performance, rotation matrices are calculated in vectorized
%   fashion, where each successive matrix extends along a third dimension. 
%   After the rotation matrix calculations, the inputted array is reshaped along the
%   third dimension, as to allow matrix multiplication along said third
%   dimension. This is an identical operation if we  were to calculate each
%   rotation matrix for each vector individually and rotate each vector
%   element. 
%
%   See:
%   https://www.mathworks.com/help/matlab/matlab_prog/vectorization.html
%   for more information on code vectorization and its benefits. 
%
%   In this vectorized fashion, all the data and rotation matrices are
%   brought into RAM together, as all calculations are performed
%   simaltaneously. If software lags, or computer runs into out of memory
%   errors, input a block size smaller than the length of series, and
%   experiment with this block size to find the best performance possible.
%   On my machine, which is i7-8700 CPU @ 3.20GHz   3.19 GHz, 86400 length
%   series was fine, but 864000 (i.e., 10Hz) was too slow. If I wanted to
%   transform a series of length 864000, I put then a block size of 86400. 
%
%------------------------------------------------------------------------------------------------------------------
%%
%--- Read variable-inputs
[block_size, higher_order_terms] = read_varargin(DATAxyzITRF, varargin); 

%---- Assign variable to time array
timeGPS = DATAxyzITRF(:,1); 

%--- Convert time GPS to time UTC (GRACE / GRACE-FO GPS time)
[timeUTC, n1] = timeGPS2UTC(timeGPS); 

%--- Assign size vector
m = 1:length(timeUTC);
    
if isequal(higher_order_terms, 1)

    %--- Convert UTC time to MDJ time
    timeMDJ = mjuliandate(timeUTC); 
    
    %--- Get polar motion 
    polarmotion = polarMotion(timeMDJ); 
    
    %--- Get CIP location adjustment 
    DCIP = deltaCIP(timeMDJ); 
    
    % Difference between (UTC) and Principal Universal Time (UT1)
    DUT1 = deltaUT1(timeMDJ); 
    
    %--- Generate ITRF to IRF rotation matrix anon. function
    dcm_fun = @(timeUTC, n1, DUT1, polarmotion, DCIP) dcmeci2ecef('IAU-2000/2006', ...
        timeUTC, n1, DUT1, polarmotion, 'dCIP', DCIP); %DCIP Xp, Yp
else 

    %--- Generate ITRF to IRF rotation matrix anon. function
    dcm_fun = @(timeUTC) dcmeci2ecef('IAU-2000/2006', ...
        timeUTC); % No higher-order terms
end

%--- Determining how to break data into chunks
block = round(linspace(1, m(end), round(m(end)/block_size)));

%--- Determining loop variable
n = 1:length(block) - 1; dcm = []; 
if isempty(n)
    block = [1, block]; 
    n = 1;
end

if isequal(higher_order_terms, 1)
%--- Higher-order calculation included by blocks    
    for i = n 
        ind = block(i):block(i+1)-1; 
        try
            dcm_loop = dcm_fun(timeUTC(ind), n1(ind), DUT1(ind), polarmotion(ind,:), DCIP(ind,:));
        catch
            dcm_loop = dcm_fun(timeUTC, n1, DUT1, polarmotion, DCIP); % Array of size n = 1 is parsed
        end
    
        dcm = cat(3, dcm, dcm_loop);
    end
    
    if ~isempty(ind)
        dcm_final = dcm_fun(timeUTC(end), n1(end), DUT1(end), ...
                polarmotion(end,:), DCIP(end,:)); 
    end
else
%--- No-higher order terms calculation by blocks
    for i = n 
        ind = block(i):block(i+1)-1; 
        try
            dcm_loop = dcm_fun(timeUTC(ind));
        catch
            dcm_loop = dcm_fun(timeUTC); 
        end
        dcm = cat(3, dcm, dcm_loop);
    end
    
    if ~isempty(ind)
        dcm_final = dcm_fun(timeUTC(end)); 
    end
end

%--- Taking inverse to make ECEF to ECI
try
    dcm = pageinv(cat(3, dcm, dcm_final));  
catch
    dcm = pageinv(dcm); 
end

%--- Transform ECEF TO ECI 
try
    DATAxyzIRF = pagewise_reshape(pagemtimes(dcm, to_pagewise_shape(DATAxyzITRF(:,2:end)))); 
catch
    DATAxyzIRF = pagemtimes(dcm, to_pagewise_shape(DATAxyzITRF(:,2:end)))'; 
end

%--- Get vector 
DATAxyzIRF = [timeGPS DATAxyzIRF];

end

%--- Function to read variable-inputs
function [block_size, higher_order_terms] = read_varargin(DATAxyzITRF, varargin)
varargin = varargin{1}; 

%--- Assign block size or use length of series if none inputted
block_ind = find(strcmpi(varargin, 'block'), 1); 
if ~isempty(block_ind) 
    block_size = varargin{block_ind+1};
    if ~isequal(floor(block_size), block_size) || block_size <= 0
        error("Input block size must be an integer and must be greater than zero"); 
    end
else
    [block_size, ~] = size(DATAxyzITRF); 
end

%--- Determine if high-order terms are required for transformation 
higher_order_terms = find(strcmpi(varargin, 'none'), 1); 
if isempty(higher_order_terms)
    higher_order_terms = 1; 
else
    higher_order_terms = 0; 
end
end
