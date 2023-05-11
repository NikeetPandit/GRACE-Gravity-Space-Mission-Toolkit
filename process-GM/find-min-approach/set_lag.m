function [ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B] ...
    = set_lag(ACC_A, ACC_B, POS_IRF_A, POS_IRF_B, SCA1B_A, SCA1B_B, Lag)
% set_lag shifts the trailing satellite to the leading satellite by a
%   constant Lag in samples. Can parse a lag to shift independently in the x,
%   y, and z direction. 
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
%   (1) ACC_A: ACC in its SRF
%   (2) ACC_B: Shifted (or lagged) trailing spacecraft measurements by Lag in SRF B
%   (3) POS_A_IRF: 
%   (4) POS_B_IRF: Shifted (or lagged) trailing spacecraft measurements by Lag
%   (5) SCA1B_A
%   (6) SCA1B_B:   Shifted (or lagged) trailing spacecraft measurements by Lag
%   
%   Notes: see compile_data for format of inputs and outputs. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
[m, n] = size(Lag);
if m~= 1 || (n~= 1 && n~= 3)
    error("Manually time-shift for trailing satellite is not correct dimension"); 
end

%--- If X, Y, Z lag is constant in all directions
if n == 1
    Lag = [Lag, Lag, Lag]; 
end

%--- Determing index parameter
n = max(Lag); n1 = n - Lag; 
%--- Indexing leading measurements 
ACC_A = ACC_A(1:end-n+1,:); 
POS_IRF_A = POS_IRF_A(1:end-n+1,:);
SCA1B_A = SCA1B_A(1:end-n+1,:); 

%--- Shifting trailing measurements by lag
ACC_B = {ACC_B(Lag(1):end-n1(1),:) ACC_B(Lag(2):end-n1(2),:) ACC_B(Lag(3):end-n1(3),:)};
POS_IRF_B = {POS_IRF_B(Lag(1):end-n1(1),:) POS_IRF_B(Lag(2):end-n1(2),:) POS_IRF_B(Lag(3):end-n1(3),:)};

%--- Interpolate SCA1B to time-shfited ACC time-tags
[SCA1B_A, SCA1B_B] = SCA1B_interp_xyz(ACC_A, ACC_B, SCA1B_A, SCA1B_B); 

end
