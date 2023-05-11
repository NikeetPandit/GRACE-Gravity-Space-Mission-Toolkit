function [lat, lon, h] = get_GRACE_coord(ID, Date, Path, TimeTag)
% get_GRACE_coord returns geodetic coordinates for a given GRACE-ID, and
%   is then interpolated to a parsed time array in GPS time. 
%
%   Time tag must be in GPS time and correspond to one "Date" of
%   measurements with at most 4 hours of padding on either side.
%
%   Function uses MATLAB's ecef2geodetic function. 
%   
%   Extrpolation is not allowed and will not be returned. Pay attention
%   for bounds of parsed in time array. 
%
%   Uses MATLAB's ecef2geodetic function. 
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Path: String carrying location of all data products.
%   (3) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) TimeTag: Time-tags in GPS time to evaluate GRACE geodetic coordinates for. 
%
%   Outputs: 
%   (1) lat: latitude in degrees.  Size [nx1]. 
%   (2) lon: lonigutde in degrees. Size [nx1]. 
%   (3) h:   height in meters.     Size [nx1]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
[~, m] = size(TimeTag);
if ~isequal(m, 1) 
    error("Dimensions of input data not correct. See documentation"); 
end
%--- Read in position data specified by ID
POS_A_ECEF = read_GNV1B_ITRF(ID, Date, Path, 'pad', 6); 

%--- Interpolate to time array and check about extrapolation 
POS_A_ECEF = interp_spline(POS_A_ECEF, TimeTag); 

%--- Debug check 
if ~isequal(length(POS_A_ECEF), length(TimeTag))
    error("SST data must be missing."); 
end

%--- Convert this to geodetic to provide location of gradient measuremetns
[lat, lon, h] = ecef2geodetic(wgs84Ellipsoid('meter'), POS_A_ECEF(:,2), POS_A_ECEF(:,3), POS_A_ECEF(:,4), 'degrees'); 

end

