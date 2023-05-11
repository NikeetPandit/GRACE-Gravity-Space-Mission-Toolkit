function [data, ind] = read_ACC(ID, Date, Path1A, Path1B, ACCprod, varargin)
% read_ACC function returns the approriate linear acceleration data product
%   depending on the inputs. 
%
%   If 1A path is parsed and the ID is "C" or "D", then ACT1A data is returned. 
%   If 1A path is not parsed and ID is "C" or "D", ACT1B data is returned. 
%   If 1A path is not parsed, and ID is "A", or "D", ACC1B data is   returned.
%   If 1A path is inputted and ID is "A", or "B", an error is returned
%
%   See read_ACT1B, read_ACT1A, read_ACC1B functions for information.
%
%   Optional: 'pad' - followed by hours to pad before/after requested Date.
%           : 'POD' - to return accelerations derived from POD. See getACCinSRFfromGPS for more info. 
%
%   Example: read_ACC("C", Date, Path1B) returns ACT1B data without padding.
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Assigning inputs
pad = find(strcmpi(varargin, 'pad'), 1);
if ~isempty(pad)
    pad = varargin{pad+1}; 
else
    pad = 0; 
end

switch ACCprod
%--- Calculating accelerations from POD
    case 'POD'
        [data, ind] = get_ACCinSRFfromGPS(ID, Date, Path1B, 'pad', pad); % see function for more info

    case 'ACT1A'
%--- Reading accelerometer data
        [data, ind] = read_ACT1A(ID, Date, Path1A, Path1B, 'pad', pad); 

    case 'ACT1B'
        [data, ind] = read_ACT1B(ID, Date, Path1B, 'pad', pad); 

    case 'ACC1B'
        [data, ind] = read_ACC1B(ID, Date, Path1B, 'pad', pad); 

    otherwise
        error("Could not determine which accelerometer data to use based on inputs."); 
end
end



