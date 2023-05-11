function [ACC_A, ACC_B, POS_A_SRF, POS_B_SRF] = transform2leadSRF(ACC_A, ACC_B, SCA1B_A, SCA1B_B, POS_A_IRF, POS_B_IRF)
% transform2leadSRF rotates all measurements to leading SRF as required for
%   GRACE gradiometery concept. 
%
%   Inputs:
%   (1) ACC_A: Leading  ACC data referenced to leading  SRF
%   (2) ACC_B: Trailing ACC data referenced to trailing SRF
%   (3) SCA1B_A: Rot. quaternions from IRF to SRF for leading satellite
%   (4) SCA1B_B: Rot. quaternions from IRF to SRF for trailing satellite
%   (5) POS_A_IRF: Coordinates in IRF for leading satellite
%   (6) POS_B_IRF: Coordinates in IRF for trailing satellite
%   
%   Outputs:
%   (1) ACC_A: Leading  ACC data referenced to leading  SRF
%   (2) ACC_B: Trailing ACC data referenced to leading SRF
%   (3) POS_A_SRF: Coordinates of leading satellite referenced in leading SRF
%   (4) POS_B_SRF: Coordinates of trailing satellite referenced in leading SRF
%   
%   Notes: see compile_data for format of inputs and outputs. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------


%--- Transform "leading" from its SRF to IRF
ACC_A = SRFtoIRF(ACC_A, SCA1B_A);  xyz = 0; 

if class(ACC_B) == "cell"
    xyz = 1; 
end

%--- Transform "trailing" from its SRF to IRF
if xyz == 1
    ACC_B = SRFtoIRF_xyz(ACC_B, SCA1B_B); 

else
    ACC_B = SRFtoIRF(ACC_B, SCA1B_B); 
end

%--- Transform "leading" from IRF to leading SRF
ACC_A = IRFtoSRF(ACC_A, SCA1B_A); 

%--- Transform "trailing" from IRF to leading SRF
if xyz == 1
    ACC_B = IRFtoSRF_xyz(ACC_B, SCA1B_A); 
else
    ACC_B = IRFtoSRF(ACC_B, SCA1B_A);
end

%--- Rotate POS of "leading" to leading SRF
POS_A_SRF = IRFtoSRF(POS_A_IRF, SCA1B_A); 

%--- Rotate POS of "trailing" to leading SRF
if xyz == 1
    POS_B_SRF = IRFtoSRF_xyz(POS_B_IRF, SCA1B_A);

else
    POS_B_SRF = IRFtoSRF(POS_B_IRF, SCA1B_A); 
end

%--- Debug check for time-tags of ACC and SST
flag = 0; 
if xyz == 1
        %-- Debug check 
    if ~isequal(ACC_B(:,1:3), POS_B_SRF(:,1:3)) || ~isequal(ACC_A(:,1), POS_A_SRF(:,1))
        flag = 1; 
    end
else
    if ~isequal(ACC_B(:,1), POS_B_SRF(:,1)) || ~isequal(ACC_A(:,1), POS_A_SRF(:,1))
        flag = 1; 
    end
end
if flag == 1
    error("Output data are not associated correctly with their time-tags. Investigate."); 
end

end