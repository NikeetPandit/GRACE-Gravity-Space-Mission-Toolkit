function dataIRF = SRFtoIRF(dataSRF, SCA1B)
% SRFtoIRF rotates a vector in SRF to IRF (Earth-Centered, Inertial)
%   using quaternions provided in SCA1B. See read_SCA1B function.
%
%   Function is vectorized for performance. See ITRFtoIRF function 
%   a discussion on computational considerations. 
%      
%   For formula relating a rotation matrix to a quaternion see (Wu et al, 2006)
%   https://podaac-tools.jpl.nasa.gov/drive/files/allData/grace/docs/ATBD_L1B_v1.2.pdf
%
%   Inputs:
%   (1) dataSRF: [timeGPS, X_dataSRF, Y_dataSRF, Z_dataSRF]. Size [nx4]. 
%   (2) SCA1B: [timeGPS, a, b, c, d]. Size [nx5], where ...
%       a Quaternion = a + bi + cj + dk.
%
%   Outputs:
%   (1)  dataIRF: [timeGPS, X_dataIRF, Y_dataIRF, Z_dataIRF]. Size [nx5]. 
%
%   timeGPS for dataSRF and SCA1B must be equivalent for transformation to be valid!
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check
[~, m] = size(dataSRF); [~, m1] = size(SCA1B); 

if ~isequal(m, 4) || ~isequal(m1,5)
    error("Improper input dimensions"); 
end

if ~isequal(dataSRF(:,1), SCA1B(:,1))
    error("Time-tags for quaternions and parsed XYZ vector must be equivalent for transformation to be valid."); 
end

%--- Assigning time vector and xyz data to own variable
time = dataSRF(:,1); dataSRF = dataSRF(:,2:end); 

%--- Reshape ACC measurements along 3rd dimension
dataSRF = to_pagewise_shape(dataSRF); 

%--- Construct quaternions along third dimension 
reshape_along_k = @(quat_component_in) reshape(quat_component_in, 1, 1, []); 

q0 =  -reshape_along_k(SCA1B(:,2)); q1 =  reshape_along_k(SCA1B(:,3)); % inverse quaternion by (Wu et al, 2006)
q2 =  reshape_along_k(SCA1B(:,4)); q3 =  reshape_along_k(SCA1B(:,5));

R_SRFtoECI = [q0.^2+q1.^2-q2.^2-q3.^2     2.*(q1.*q2+q0.*q3)     2.*(q1.*q3-q0.*q2); ... % rotation matrix by (Wu et al, 2006)
    2.*(q1.*q2-q0.*q3)         q0.^2-q1.^2+q2.^2-q3.^2 2.*(q2.*q3+q0.*q1); ... 
    2.*(q1.*q3+q0.*q2)         2.*(q2.*q3-q0.*q1)     q0.^2-q1.^2-q2.^2+q3.^2];

%--- Transform measurements to IRF
try
    dataIRF = pagewise_reshape(pagemtimes(R_SRFtoECI, dataSRF)); 
catch
    dataIRF = (pagemtimes(R_SRFtoECI, dataSRF))'; 
end

%--- Compile vector
dataIRF = [time dataIRF]; 

end
































