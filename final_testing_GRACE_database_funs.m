%----------- TESTING GRACE DATABASE FUNCTIONS -----------%
%   Some testing for GRACE database functions. This is non exhaustive
%   of all the testing that has actually been done. The motivation is to serve
%   as a final validation check to ensure everything works as documented on my machine. 

%--- Adding path
addpath(genpath('funs')); clearvars; close all

%--- Setting constants
PathB = 'E:\DATA-PRODUCTS\GRACE-Data\GRACE-2010';
Date = datetime(2010, 1, 1);

%--- SCA1B 
data = read_SCA1B("A", Date, PathB); 


%--- POS testing and transformation check 
POS_IRF = read_GNI1B_IRF("A", Date, PathB); 
POS_ITRF = read_GNV1B_ITRF("A", Date, PathB); 
isequal(POS_ITRF(:,1), POS_IRF(:,1)) %time stamps are equal as expected. 

%--- KBR1B testing
data = read_KBR1B("A", Date, PathB); 

%--- ACC1B testing 
data = read_ACC1B("A", Date, PathB); %good


% LOGS 
% Calib_ACC been checked and looks good. Everything else looks good. 