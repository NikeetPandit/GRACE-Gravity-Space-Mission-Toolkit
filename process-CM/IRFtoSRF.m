function dataSRF = IRFtoSRF(dataIRF, SCA1B)
% IRFtoSRF rotates a vector in in IRF (Earth-Centered, Inertial) to SRF.
%   See SRFtoIRF function for more information. 
%
%   Inputs:
%   (1) dataIRF: [timeGPS, X_dataIRF, Y_dataIRF, Z_dataIRF]. Size [nx4]. 
%   (2) SCA1B: [timeGPS, a, b, c, d]. Size [nx5], where ...
%       a Quaternion = a + bi + cj + dk.
%
%   Outputs:
%   (1)  dataSRF: [timeGPS, X_dataSRF, Y_dataSRF, Z_dataSRF]. Size [nx5].
%
%   timeGPS for dataSRF and SCA1B must be equivalent for transformation to be valid!
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check
[~, m] = size(dataIRF); [~, m1] = size(SCA1B); 
if ~isequal(m, 4) || ~isequal(m1,5)
    error("Improper input dimensions"); 
end

%--- Assigning time vector and xyz data to own variable
time = dataIRF(:,1); dataIRF = dataIRF(:,2:end); 

%--- Reshape ACC measurements along 3rd dimension
dataIRF = to_pagewise_shape(dataIRF); 

%--- Construct quaternions along third dimension 
reshape_along_k = @(quat_component_in) reshape(quat_component_in, 1, 1, []); 

q0 =  reshape_along_k(SCA1B(:,2)); q1 =  reshape_along_k(SCA1B(:,3)); 
q2 =  reshape_along_k(SCA1B(:,4)); q3 =  reshape_along_k(SCA1B(:,5)); 

R_ECItoSRF = [q0.^2+q1.^2-q2.^2-q3.^2     2.*(q1.*q2+q0.*q3)     2.*(q1.*q3-q0.*q2); ... % rotation matrix by (Wu et al, 2006)
    2.*(q1.*q2-q0.*q3)         q0.^2-q1.^2+q2.^2-q3.^2 2.*(q2.*q3+q0.*q1); ... 
    2.*(q1.*q3+q0.*q2)         2.*(q2.*q3-q0.*q1)     q0.^2-q1.^2-q2.^2+q3.^2];

%--- Transform measurements to IRF
try
    dataSRF = pagewise_reshape(pagemtimes(R_ECItoSRF, dataIRF)); 
catch
    dataSRF = (pagemtimes(R_ECItoSRF, dataIRF))'; 
end

%--- Compile vector
dataSRF = [time dataSRF]; 

end































