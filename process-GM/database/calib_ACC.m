function [ACCDataOut, bias] = calib_ACC(ACCDataIn, ID)
% CALIB_ACC Applies bias and calibration factors to ACC1B data
%   
%   Function is called under-the-hood when ACC1B data is read in for GRACE.
%
%   See for more info: https://podaac-tools.jpl.nasa.gov/drive/files/allData/grace/docs/TN-02_ACC_CalInfo.pdf
%   Version2 has corrections applied in SRF. 
%
%   Inputs:
%   (1) ACCDataIn: Interpreted as [time, X, Y, Z].
%   (2) ID:        "A" or "B" GRACE identifier.
%
%   Outputs:
%   (1) ACCDataOut: Accelerometer data returned with applied factors as [time, X, Y, Z].
%   (2) bias: Evaluated bias for each acceleromter measurement time stamp.
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Assinging variables
timeGPS = ACCDataIn(:,1); ACCxyzIn = ACCDataIn(:,2:end);

switch ID
    case "A"
        scale = [0.9595 0 0; 0 0.9797 0; 0 0 0.9485];
    case "B"
        scale = [0.9465 0 0; 0 0.9842 0; 0 0 0.9303];
    otherwise
        error("Invalid ID selection."); 
end

%--- Determing reference time T0 and associated biases
reference_date = datetime(2003, 3, 7); 

if (timeGPS2dt(timeGPS(1)) < reference_date)

    %--- Setting reference epoch 
    T0 = 52532; 

    switch ID
        case "A"
            
            %--- Biases for GRACE-A data before March 7, 2003
            C0 = [-1.106; 27.042; -0.5486].*1e-6; % Converting biases to m
            C1 = [2.233e-4; 4.46e-3; -1.139e-6].*1e-6; 
            C2 = [2.5e-7; 1.1e-6; 1.7e-7].*1e-6; 

        case "B"

            %--- Biases for GRACE-B data before March 7, 2003
            C0 = [-0.5647; 7.5101; -0.8602].*1e-6; 
            C1 = [-7.788e-5; 7.495e-3; 1.399e-4].*1e-6; 
            C2 = [2.4e-7; -9.6e-6; 2.5e-7].*1e-6; 
    end
else

    %--- Setting reference epoch 
    T0 = 53736; 

    switch ID
        case "A"

            %--- Biases for GRACE-A data after March 7, 2003
            C0 = [-1.2095; 29.3370; -0.5606].*1e-6; % Converting biases to m
            C1 = [-4.128e-5; 6.515e-4; -2.352e-6].*1e-6; 
            C2 = [9.7e-9; -3.9e-7; 3.8e-9].*1e-6; 

        case "B"

            %--- Biases for GRACE-B data after March 7, 2003
            C0 = [-0.6049; 10.6860; -0.7901].*1e-6; 
            C1 = [-1.982e-5; 1.159e-3; 4.783e-5].*1e-6; 
            C2 = [3.5e-9; -4.3e-7; -6.5e-9].*1e-6; 
    end
end 

%--- Convert GPS time to julian data
Td = mjuliandate(timeGPS2UTC(timeGPS)); elapsed_epoch = reshape(Td - T0, 1, 1, []); 

%--- Determine bias from quadratic fit
bias = C0 + pagemtimes(C1,elapsed_epoch) + pagemtimes(C2,(elapsed_epoch.^2));  

%--- Apply scale and evaluated bias factors to inputted accelerometer data
ACCxyzOut = pagewise_reshape(bias + pagemtimes(scale, to_pagewise_shape(ACCxyzIn))); 

%--- Compile vector out
ACCDataOut = [timeGPS ACCxyzOut]; 

end




