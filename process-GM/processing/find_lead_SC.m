function [ID_Lead, ID_Trail] = find_lead_SC(POS_IRF_A, SCA1B_A)
% find_lead_sc determines the leading GRACE mission spacecraft. 
%   The reference of leading is taken along the satellite flight path.
%   
%   Inputs:
%   (1) POS_IRF_A: SST pos data of "A" or "C"
%   (2) SCA1B_A: : SCA1B   data of "A" or "C"
%
%   Outputs:
%   (1) ID_Lead:      Char to denote leading spacecraft. "A", "B", "C", or "D"
%   (2) ID_Trail:     Char to denote trailing spacecraft.
%
%   The SRF of GRACE and GRACE-FO spacecraft have its positive X-axis SRF
%   pointing toward the other spacecraft. Rotating SST coordinates in IRF
%   to the SRF of either GRACE "A", or GRACE-FO "C", we may determine which
%   satellite is leading along the satellite trajectory. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------
%--- Determine if date corresponds to GRACE or GRACE-FO
mission = det_GRACEmission(timeGPS2dt(POS_IRF_A(1,1))); 

if      isequal(mission, 'GRACE')
    ID = ["A", "B"]; 
    
elseif  isequal(mission, 'GRACE_FO') 
    ID = ["C", "D"]; 

end
 
%--- Rotate IRF position data to "A" or "C" GRACE-ID
POS_SRF_A = IRFtoSRF(POS_IRF_A(1:2,:),  interp_spline(SCA1B_A, [POS_IRF_A(1,1); POS_IRF_A(1,1)])); 

%--- Velocity of GRACE "A" or "C" in SRF
velSRFx = diff(POS_SRF_A(:,2)); 

if     velSRFx < 0

    %--- Leading is A or C and trailing is B or D
    ID_Lead = ID(1); ID_Trail = ID(2);

elseif velSRFx > 0 

    %--- Leading is B or D and Trailing is A or C
    ID_Lead = ID(2); ID_Trail = ID(1); 

else
    error("Could not determine which is the leading or..." + ...
        "trailing satellite. Or, satellites are performing a switching maneouver."); 
end

end

% POS_SRF_A = IRFtoSRF(POS_IRF_A, interp_spline(SCA1B_A, POS_IRF_A(:,1))); % Interpolate SCA1B to SST time-tags
