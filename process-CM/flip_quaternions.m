function [SCA1B, Flag] = flip_quaternions(SCA1B)
% flip_quaternions flips signs, if needed, for all 4 quaternions to maintain
%   continuity in time. It is recommended to use flip_quats_SCA1B after reading 
%   in SCA1B data for GRACE and GRACE-FO. 
%
%   The motiviation is to ensure reliable interpolation of SCA1B data.
%   These discontinuties in time cause wildly unreliable interpolation
%   around these points. 
% 
%   This processing step is described in the algoithm theoretical 
%   basis document for GRACE V1.2, but is often not corrected for GRACE.
%   This software employs a series of outlier checks and filtering
%   processes. A few different methods were experimented, but this one
%   performed the best in efficiency and accurarcy. Routine uses MATLAB's hampel
%   filter in one step. 
%
%   This algorithm has been rigerously tested. It will not work when
%   the SCA1B data starts out flipped, or ends flipped. In
%   this case, there is a flag, and error that is released to inform the
%   user of any potential error. Padding the data when using
%   read_SCA1B data with a few hours before or after a requested date will
%   ensure very high probability that this function works as intended, for
%   the actual requested date. 
%
%   Flipping the signs for all 4 quaternions is a valid
%   operations since any rotation on a quaternion sphere can either be carried 
%   by the positive or negative roation. 
%
%   Inputs:
%   (1): SCA1B: [time, a, b, c, d] where Quaternion = a + bi + cj, + dk. Type double. Size [nx5]. 
%
%   Outputs:
%   (1): Same as input (1) with possible flips to maintain continuity in time. 
%   (2): Flag: returns 1 if there is a possible uncorrected flip. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------



%--- Debug checks 
[~, n] = size(SCA1B); 
if ~isequal(n, 5)
    error("Improper input dimensions"); 
end

%% Hampel Outlier Detection Preliminary

%--- Hampel outlier filter for ONE flip removal
[~, ind] = hampel(SCA1B(:,2:end)); 

%--- Find row-wise min to find only flips which occur simaltaneously
ind = min(ind, [], 2); 

%--- Flipping where outliers have been identified
SCA1B(ind,2:end) = SCA1B(ind,2:end)*-1; 


%% First Round Outlier Detection

%--- Doing a HP diff filter of quats
HP = diff(SCA1B(:,2:end),1); 

%--- Find where HP is large to determine flip 
outlier = cat(1, [false false false false], HP >= 0.05 & SCA1B(2:end,2:end) > 0 | ...
    HP <= -0.05 & SCA1B(2:end,2:end) < 0); %threshold was determined experimentally

%--- Find row-wise min to find only outliers which occur simaltaneously
outlier = min(outlier, [], 2); 

%--- Extracting inds where logical is true
ind = find(outlier == 1);

%--- Shifting outlier end back 1 elements
even_elements = 2:2:length(ind); 
ind(even_elements) = ind(even_elements) - 1; 

%--- Generate new logical array with array indicating start and stop end of outlier which itself is an outlier
outlier = zeros(length(SCA1B), 1); 
outlier(ind) = 1; 

%--- Making in between start and stop of each outlier ... an outliers
for i = 1:2:length(ind)-1
    outlier(ind(i):ind(i+1)) = 1; 
end

%--- Converting back to logical array
outlier = logical(outlier); 

%--- Flipping discontinuties of SCA1B to make continuous in time 
SCA1B(outlier, 2:end) = SCA1B(outlier, 2:end)*-1; 

%--- Variable Assignment 
SCA1B_First_Round = SCA1B; 

%% Second round of outlier detection 

%--- Doing a simple HP difference filter of input quaternions
HP = diff(SCA1B(:,2:end),1); 

%--- Find where HP is large + provided sample rate is nominal 
outlier = cat(1, [false false false false], HP >= 0.05 & SCA1B(2:end,2:end) > 0 | ...
    HP <= -0.05 & SCA1B(2:end,2:end) < 0); 

outlier = sum(outlier, 2) >= 2; 

%--- Extracting inds where logical is true
ind = find(outlier == 1);

%--- Shifting outlier end back 1 elements
even_elements = 2:2:length(ind); 
ind(even_elements) = ind(even_elements) - 1; 

%--- Generate new logical array with array indicating start and stop end of outlier which itself is an outlier
outlier = zeros(length(SCA1B), 1); 
outlier(ind) = 1; 

%--- Making in between start and stop of each outlier ... an outliers
for i = 1:2:length(ind)-1
    outlier(ind(i):ind(i+1)) = 1; 
end

%--- Converting back to logical array
outlier = logical(outlier); 

%--- Flipping discontinuties of SCA1B to make continuous in time 
SCA1B(outlier, 2:end) = SCA1B(outlier, 2:end)*-1; 

SCA1B_Second_Round = SCA1B; 

%-- Checking to see if introduced any spikes in second round
Test1 = sum(sum(abs(diff(SCA1B_First_Round(:,2:end), 1))));
Test2 = sum(sum(abs(diff(SCA1B_Second_Round(:,2:end), 1))));

if     Test1 > Test2
    SCA1B = SCA1B_Second_Round; 
elseif Test1 < Test2
     SCA1B = SCA1B_First_Round; 
else
    SCA1B = SCA1B_First_Round; 
end

%% Determing if the SCA1B starts flipped or ends flipped 

%--- Doing a HP diff filter of quats
HP = diff(SCA1B(:,2:end),1); 

%--- Find where HP is large to determine flip 
outlier = cat(1, [false false false false], HP >= 0.05 & SCA1B(2:end,2:end) > 0 | ...
    HP <= -0.05 & SCA1B(2:end,2:end) < 0); %threshold was determined experimentally

%--- Find row-wise min to find only outliers which occur simaltaneously
outlier = min(outlier, [], 2); 

%--- Extracting inds where logical is true
ind = find(outlier == 1);

%--- If array ind is odd.. the SCA1B data starts out flipped or ends flipped 
if isequal(mod(length(ind), 2), 1)
    warning(cat(2, 'Input SCA1B prod. may start flipped or end flipped. There is likely flips yet to be corrected... Investigate ', datestr(timeGPS2dt(SCA1B(1,1)))))
    Flag = 1; 
else
    Flag = 0; 
end

end