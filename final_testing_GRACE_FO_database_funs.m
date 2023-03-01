%----------- TESTING GRACE-FO DATABASE FUNCTIONS -----------%
%   Some testing for GRACE-FO database functions. This is non exhaustive
%   of all the testing that has actually been done. The motivation is to serve
%   as a final validation check to ensure everything works as documented on my machine. 

%--- Adding path
addpath(genpath('funs')); clearvars; close all

%--- Setting constants
PathB = 'F:\DATA-PRODUCTS\GRACE-FO-1B\2018-2022'; 
PathA = 'E:\DATA-PRODUCTS\GRACE-FO-1A\2018-2022'; 
Date = datetime(2020, 4, 14);

%--- ACT1B testing 
[data, ind] = read_ACT1B("C", Date, PathB); 

%--- SCA1B 
data = read_SCA1B("C", Date, PathB); 

% --- TIM1B
data = read_TIM1B("C", Date, PathB, 'pad', 3); 

% --- CLK1B
data = read_CLK1B("C", Date, PathB, 'pad', 3); 


%--- POS testing and transformation check 
POS_IRF = read_GNI1B_IRF("C", Date, PathB); 
POS_ITRF = read_GNV1B_ITRF("C", Date, PathB); 
POS_IRF_Calc = ITRFtoIRF(POS_ITRF, 'none'); 

[lat, lon, h] = ecef2geodetic(wgs84Ellipsoid('meter'), POS_ITRF(:,2), POS_ITRF(:,3), POS_ITRF(:,4)); 

figure(1); 
for i = 1:3
    subplot(3,1,i)
    plot((POS_IRF(:,i+1) - POS_IRF_Calc(:,i+1)))
end

%--- KBR1B testing
data = read_KBR1B("D", Date, PathB); 

%--- ACT1A testing 
data = read_ACT1A("D", Date, PathA, PathB); 
data1 = read_ACT1B("D", Date, PathB); 
[b, a] = butter(1, [10^-4 10^-1]./(1/2), 'bandpass'); %setting 2 for 1Hz upsample
data1(:,2:end) = filtfilt(b, a, data1(:,2:end)); 

[b, a] = butter(2, [10^-4 10^-1]./(10/2), 'bandpass'); %setting 2 for 1Hz upsample
data(:,2:end) = filtfilt(b, a, data(:,2:end)); 
figure; 
for i = 1:3
subplot(3,1,i)
plot(data(:,1), data(:,i+1)); hold  on 
plot(data1(:,1), data1(:,i+1));
end

%--- ACT1A testing mapping 
data = read_ACT1A("D", Date, PathA, PathB); 
test = timeOBC2GPS(data(:,1), "D", Date, PathB); 


%--- THR1B testing 
data = read_THR1B("D", Date, PathB); 

% LOGS 
% Start and end data corresponds to data file when visually inspected. 
% Few random points also correspond to data file. Plotting data file yields
% expected X, Y, Z accelerations for GRACE missions. 
%
% Padding functionality looks good in test cases. Placing padding values
% that are out of range results in error message, as intended. Putting
% decimals for the padding value results in rounding the value to an
% integer as intended. This means truncate_data2pad works as intended. 
% 
% TimeGPS2dt passes debug checks. Edge cases provide expected datetime
% object. For example, the first GPS epoch loaded in and converted to GPS
% time datetime object -> 14-Apr-2020 0h. When using timeGPS2UTC it gives 
% 13-Apr-2020 23:59:42, which makes perfect sense since GPS time is now
% ahead of UTC time by 18 seconds. 
%
% SCA1B files are read in and validated using manual expection and edge
% cases. 
%
% Ditto for TIM1B/CLK1B
%
% GNV1B and GNI1B read looks good. Transformations validate really well
% against JPL's when using higher-order terms. 
%
% KBR1B is good. 
%
% ACT1A transformation to SRF is good from AF. When loading in noisy ACT1A
% data and filtering to same bandwidth as dwownsampled ACT1B for
% GRACE-C/D... data corresponds visually as expected. Time mapping looks as
% expected and linear drift looks to be a good choice when the mappings
% periodically reset as it fills the gap nicely. At most 10ms difference
% which is corresponds to the mapping files and makes sense since the drift
% should be very small anyway. 
%
% THR1B is good. 