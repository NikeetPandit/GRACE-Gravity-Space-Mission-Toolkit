function [indexA, indexB] = minDistSRF_xyz(pos_A, pos_B, SCA1B_A, dist_constraint)
%MINDistSRF_xyz finds the closest approach of a trailing satellite to a fixed leading 
%   satellite. The minimum 3-D vector seperation is found in the X, Y, and Z
%   independently of each-other. 
%
%   The minimum 3-D seperation is found between the two spacecraft where
%   position data has been rotated and referenced to the leading SRF at
%   each minimization point. Can find closest approach with respect to zero, or specify closest
%   approach to some other constant.
%
%   See the description of the algorithm for gradiometer for more details. 
%
%   Inputs:
%   (1) posA, [nx4] input matrix interpreted as [time, X, Y, Z]. Position
%       data for leading spacecraft in ECI. 
%   (2) posB, [nx4] input matrix interpreted as [time, X, Y, Z]. Position
%       data for trailing spacecraft in ECI.
%   (3) SCA1B_A, [nx5] input matrix interpreted as [time, a, b, c, d] where
%       Quaternion = a + bi + cj, + dk. SCA1B data for leading spacecraft. 
%   (4) dist_constraint, [dist_constraint_X, dist_constraint_Y,
%       dist_constraint_Z]. Can find the cloest value to zero (i.e, the
%       true minimum approach) by placing [0, 0, 0]. Or, can find the
%       minimum appproach to some other constant by placing into the
%       vector. Size is [1x3]. 
%   'leader': Place variable input to specify leader stays the leader 
%             if want to find a minimum approach between the two spacecraft
%             constrained to the fact that leader spacecraft stays the
%             leader in the minimum approach of fixed leading and
%             free-flying trailing. 
%   'trailer': Same as 'leader" except trailer. Meaning, the leading is
%              actually always trailing when finding the minimum approach. 
%
%   Outputs: 
%   (1) posA, [nx4] matrix interpreted as [time, X, Y, Z]. Position
%       data for leading spacecraft in SRF
%   (2) posB, [nx6] matrix interpreted as [timeX, timeY, timeZ, X, Y, Z]
%       corresponding to the timeshifts and associated position data in
%       leading SRF that brings the trailing spacecraft closest to the
%       leading spacecraft, constrained on dist_constrain and variable
%       input 'leader' or 'trailer', or no forcing. 
%
%   (3) indexA, [nx1], indicies to extract data associated to the closest
%       approach of a fixed leading spacecraft. This is simply the leading
%       spacecraft data trunacted by [see line 67]
%   (4) indexB, [nx3], indicies to extracted data associated to the cloesst
%       approach of a free-flying traailing spacecraft in the X, Y, Z
%       independently. Interpreted as [Index_X, Index_Y, Index_Z]
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Isolating time vector from POS inputs
time_A = pos_A(:,1); 
time_B = pos_B(:,1); 

%--- Determining average sampling rate 
M_A = avg_sample_rate(time_A);
M_B = avg_sample_rate(time_B); 
if ~isequal(M_A, M_B)
    error("Dimensions of input data not correct. See documentation"); 
else
    M = M_A; clear M_A M_B
end

%--- Scaling sample rate by range to find minimization for
M1 = M * 45; 
M0 = M * 15; 

%--- Minimize 3D seperation in SRF

%--- Get loop variables
n = length(pos_A) - M1; n = 1; 
index = [(1:n) + M0; (1:n) + M1]; 

%--- Transform leading SST in ECI to leading SRF
min3DposA_SRF = IRFtoSRF(pos_A(1:n,:), SCA1B_A(1:n,:)); 

%--- Finding index shift for min 3D distance (brute force)
ind_min_X = zeros(1,n); ind_min_Y = ind_min_X; ind_min_Z = ind_min_Y; 

for i = 1
    %--- Transforming indexed POS of B to leading A
    search_minB = IRFtoSRF(pos_B(index(1,i):index(2,i),:), SCA1B_A(i, :));

    %--- 3D Vector seperation referenced to trailing 
    search_min = search_minB(:,2:end) - min3DposA_SRF(i,2:end);
    
    %--- Finding min 3D vector seperation in leading SRF based for XYZ

    [~, ind_min_X(i)] = min(abs((search_min(:,1)) - dist_constraint(1))); % find closest to dist constraint (where "leading" lead or trail)
    [~, ind_min_Y(i)] = min(abs((search_min(:,2)) - dist_constraint(2)));
    [~, ind_min_Z(i)] = min(abs((search_min(:,3)) - dist_constraint(3)));
  
end

%--- Extracting GPS time epochs where min. distance occurs by shifting trailing to leading
indexB_X = (0:n-1) + M0 + ind_min_X; %index needed for extraction
indexB_Y = (0:n-1) + M0 + ind_min_Y; 
indexB_Z = (0:n-1) + M0 + ind_min_Z; 
indexB = [indexB_X' indexB_Y' indexB_Z']; 
indexA = 1:n;       



end



