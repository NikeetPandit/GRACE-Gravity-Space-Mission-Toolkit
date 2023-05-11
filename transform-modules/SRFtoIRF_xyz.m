function DATAxyz_ECI = SRFtoIRF_xyz(DATAxyz_SRF, SCA1B)
% SRFtoIRF_xyz rotates data in SRF to IRF. 
%
%   See SCA1B_interp_xyz and SRFtoIRF function for more info.
%
%   Inputs: 
%   (1) Dataxyz_SRF: Convention of output (x) in any function...
%
%   (2) SCA1B: Convention of output (2) in SCA1B_interp_xyz function. 
%
%   Outputs:
%   (1) DATAxyz_ECI: Same convention as input(1), referenced in IRF
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Get SCA1B and DATA for XYZ from cell
SCA1B_X = SCA1B{1}; 
SCA1B_Y = SCA1B{2}; 
SCA1B_Z = SCA1B{3}; 

DATAx = DATAxyz_SRF{1}; 
DATAy = DATAxyz_SRF{2}; 
DATAz = DATAxyz_SRF{3}; 

%--- Debug check 
if ~isequal(SCA1B_X(:,1), DATAx(:,1)) || ~isequal(SCA1B_Y(:,1), DATAy(:,1))  || ~isequal(SCA1B_Z(:,1), DATAz(:,1)) 
    error("Time-tags of SCA1B and DATAxyz inputs are not associated correctly."); 
end
 
%--- Construct rotation matrix which corresponds to X measurements
R_SRFtoECI_X = SRFtoIRF(DATAx, SCA1B_X, 'rotation'); 

%--- Construct rotation matrix which corresponds to Y measurements
R_SRFtoECI_Y = SRFtoIRF(DATAy, SCA1B_Y, 'rotation'); 

%--- Construct rotation matrix which corresponds to Z measurements
R_SRFtoECI_Z = SRFtoIRF(DATAz, SCA1B_Z, 'rotation');

%--- Reshape DATA measurements along 3rd dimension
DATAx = to_pagewise_shape(DATAx(:,2:end)); 
DATAy = to_pagewise_shape(DATAy(:,2:end)); 
DATAz = to_pagewise_shape(DATAz(:,2:end)); 

%--- Transform DATA measurements to ECI
try
    DATA_xyz_ECIx = pagewise_reshape(pagemtimes(R_SRFtoECI_X, DATAx)); 
    DATA_xyz_ECIy= pagewise_reshape(pagemtimes(R_SRFtoECI_Y, DATAy)); 
    DATA_xyz_ECIz = pagewise_reshape(pagemtimes(R_SRFtoECI_Z, DATAz)); 
catch
    DATA_xyz_ECIx = (pagemtimes(R_SRFtoECI_X, DATAx)); 
    DATA_xyz_ECIy= (pagemtimes(R_SRFtoECI_Y, DATAy)); 
    DATA_xyz_ECIz = (pagemtimes(R_SRFtoECI_Z, DATAz)); 
end

%--- Compile output
DATAxyz_ECI = {[DATAxyz_SRF{1}(:,1)  DATA_xyz_ECIx], [DATAxyz_SRF{2}(:,1)  DATA_xyz_ECIy] ...
    [DATAxyz_SRF{3}(:,1)  DATA_xyz_ECIz]};

end
