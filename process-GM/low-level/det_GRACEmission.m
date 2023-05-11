function ID = det_GRACEmission(Date)
% det_GRACEmission determines if the mission is GRACE or GRACE-FO based on
%   a parsed date.
%
%   Inputs:
%   (1) Date: Specifying date of data product to load. Type Datime. Size 1. 
%
%   Outputs:
%   (1) Mission: 'GRACE' or 'GRACE_FO'
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
if ~isequal(class(Date), 'datetime')
    error("Input must be type datetime.");
end

if      Date >= datetime(2002, 4, 4) && Date <=  datetime(2017, 6, 29)
    ID = 'GRACE'; 

elseif  Date >= datetime(2018, 5, 22); 
    ID = 'GRACE_FO'; 

else
    error("Selected date does not correspond to a GRACE mission."); 
end
    
end