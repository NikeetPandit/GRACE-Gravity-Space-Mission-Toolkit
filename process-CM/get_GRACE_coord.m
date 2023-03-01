function [lat, lon, h] = get_GRACE_coord(ID, Date, Path, TimeArray)
% get_GRACE_coord returns geodetic coordinates for a given GRACE-ID, and
%   is then interpolated to a parsed time array in GPS time. 
%   
%   Extrpolation is not allowed and will not be returned. Pay attention
%   for bounds of parsed in time array. 
%
%   Uses MATLAB's ecef2geodetic function. 
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product. 
%
%   Outputs: 
%
%   (1), lat: latitude in degrees. Size [nx1]. 
%   (2), lon: lonigutde in degrees. Size [nx1]. 
%   (3), h: height in meters. Size [nx1]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
[~, m] = size(TimeArray);
if ~isequal(m, 1) 
    error("Dimensions of input data not correct. See documentation"); 
end

% Read in position data specified by ID
POS_A_ECEF = read_GNV1B_ECEF_day(ID, Date, Path, 'pad', 4); 

%--- Interpolate to time array and check about extrapolation 
POS_A_ECEF = interp_spline(POS_A_ECEF, TimeArray); 

%--- Convert this to geodetic to provide location of gradient measuremetns
[lat, lon, h] = ecef2geodetic(wgs84Ellipsoid('meter'), POS_A_ECEF(:,2), POS_A_ECEF(:,3), POS_A_ECEF(:,4), 'degrees'); 

end