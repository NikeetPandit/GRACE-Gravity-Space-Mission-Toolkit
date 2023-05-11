function DATAxyz_SRF = IRFtoSRF_xyz(DATAxyz_IRF, SCA1B)
% IRFtoSRF_xyz rotates data in IRF to SRF. 
%
%   See SCA1B_interp_xyz and SRFtoIRF function for more info.
%
%   Once the 3 arrays of 3-D accelerations are rotated to the leading SRF,
%   the x, y, z components are extrated as they correspond to the leading
%   x, y, z SRF.
%
%   Inputs: 
%   (1) Dataxyz_IRF: Convention of output (x) in any function...
%
%   (2) SCA1B: Quaternions to rotate IRF data to SRF to.
%
%   Outputs:
%   (1) DATA_xyz_SRF: [timeX, timeY, timeZ, DATA_X, DATA_Y, DATA_Z]. 
%       Each time array corresponds to a time-shift or lag which brings the
%       trailing satellite closest to a fixed leading satellite along each
%       3-D axis in the leading SRF. 
%
%       See functions in X function. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Extract DATA matrix for XYZ from cell
DATAx = DATAxyz_IRF{1}; 
DATAy = DATAxyz_IRF{2}; 
DATAz = DATAxyz_IRF{3};

%--- Construct IRF to SRF rotation matrix
R_ECItoSRF = IRFtoSRF(DATAx, SCA1B, 'rotation'); 

%--- Reshape DATA measurements along 3rd dimension
DATAx = to_pagewise_shape(DATAx(:,2:end)); 
DATAy = to_pagewise_shape(DATAy(:,2:end)); 
DATAz = to_pagewise_shape(DATAz(:,2:end)); 

%--- Transform DATA Measurements to SRF
try
    DATA_xyz_ECIx = pagewise_reshape(pagemtimes(R_ECItoSRF, DATAx)); 
    DATA_xyz_ECIy= pagewise_reshape(pagemtimes(R_ECItoSRF, DATAy)); 
    DATA_xyz_ECIz = pagewise_reshape(pagemtimes(R_ECItoSRF, DATAz));

catch
    DATA_xyz_ECIx = (pagemtimes(R_ECItoSRF, DATAx)); 
    DATA_xyz_ECIy= (pagemtimes(R_ECItoSRF, DATAy)); 
    DATA_xyz_ECIz = (pagemtimes(R_ECItoSRF, DATAz)); 

end

%--- Compile output in SRF
DATA_xyz = {[DATAxyz_IRF{1}(:,1)  DATA_xyz_ECIx], [DATAxyz_IRF{2}(:,1)  DATA_xyz_ECIy] ...
    [DATAxyz_IRF{3}(:,1)  DATA_xyz_ECIz]};

DATAxyz_SRF = [DATA_xyz{1}(:,1) DATA_xyz{2}(:,1) DATA_xyz{3}(:,1) ...
    DATA_xyz{1}(:,2) DATA_xyz{2}(:,3) DATA_xyz{3}(:,4)]; 

end




