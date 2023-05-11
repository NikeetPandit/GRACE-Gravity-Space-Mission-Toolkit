function [SCA1B_A, SCA1B_B] = SCA1B_interp_xyz(ACC_A, ACC_B, SCA1B_A, SCA1B_B)
% SCA1B_interp_xyz interpolates SCA1B data to accelerometer measurement
%   time stamps. The time-shifts that brings a trailing satellite to a
%   fixed satellite may occur at different instances in the X, Y, Z
%   directions (in leading SRF).
%
%   Therefore, there are three arrays of 3-D accelerations associated to
%   a closest approach with independent and potentially different associated
%   attitude angles, provided in the SCA1B data product. 
%
%   This function interpolates the independent attitude angles to the three
%   independent arrays of 3-D, time shifted, trailing spacecraft 
%   accelerations. 

%   Inputs:
%   (1) ACC_A: Leading ACC data referenced to leading SRF. 
%
%   (2) ACC_B  Trailing ACC data which is time-shifted to be at closest
%   approach in X, Y, Z directions independently. Type cell. 
%   Interpreted as: {ACC_X_MIN, ACC_Y_MIN, ACC_Z_MIN}
%
%   (3) SCA1B_A: Rot. quaternions from IRF to SRF for leading satellite
%   (4) SCA1B_B: Rot. quaternions from IRF to SRF for trailing satellite
%   
%   Output:
%   (1): SCA1B_A: Quaternions interpolated to time-tags of input (1)
%   (2)  SCA1B_B: Quaternions interpolated to time-tags of input (2). Type cell.
%              
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Leading spacecraft interpolated upsampled 0.2Hz SLERP SCA1B data to ACC-time stamps via splines
SCA1B_A = [ACC_A(:,1) interp1(SCA1B_A(:,1), SCA1B_A(:,2:end), ACC_A(:,1), 'spline', NaN)];

%--- X Component of min approach 
SCA1B_B_X = [ACC_B{1}(:,1) interp1(SCA1B_B(:,1), SCA1B_B(:,2:end), ACC_B{1}(:,1), 'spline', NaN)]; 

%--- Y Component of min approach 
SCA1B_B_Y = [ACC_B{2}(:,1) interp1(SCA1B_B(:,1), SCA1B_B(:,2:end), ACC_B{2}(:,1), 'spline', NaN)]; 

%--- Z Component of min approach 
SCA1B_B_Z = [ACC_B{3}(:,1) interp1(SCA1B_B(:,1), SCA1B_B(:,2:end), ACC_B{3}(:,1), 'spline', NaN)]; 

%--- Extrapolation Debug Check
if any(isnan(SCA1B_A(:))) || any(isnan(SCA1B_B_X(:))) || any(isnan(SCA1B_B_Y(:))) || any(isnan(SCA1B_B_Z(:)))
    error("All data that may have been extrapolated should have been removed already. Gross error somewhere. Investigate");
end
 
%--- Constructing cell output
SCA1B_B = {SCA1B_B_X, SCA1B_B_Y, SCA1B_B_Z}; 

end


