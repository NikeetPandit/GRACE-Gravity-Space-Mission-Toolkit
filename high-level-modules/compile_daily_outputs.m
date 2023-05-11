function output = compile_daily_outputs(inputs, ACC_A, ACC_B, POS_A_SRF, POS_B_SRF, ACCDateEpochs)

%--- Assign input structure to variables
ID = inputs.GRACE_ID; Path1B = inputs.Path1B; 
Date = inputs.Processing_Day; ACCprod = process_inputs(inputs); 

%--- Determine if one or two mode operation 
[~, m] = size(POS_B_SRF); 
if m > 4
    twoMode = 1; 
else 
    twoMode = 0; 
end


[lat, lon] = get_GRACE_coord(ID, Date, Path1B, ACC_A(:,1));

%--- Find gaps in SCA1B data 
try
    if twoMode == 1 
        ind_SCA1B_gaps = find_SCA1B_gaps(2, Path1B, [ACC_A(:,1), ACC_B(:,1:3)]);

    else
        ind_SCA1B_gaps = find_SCA1B_gaps(1, Path1B, [ACC_A(:,1), ACC_B(:,1)], ID);
    end

catch
    output = []; disp(cat(2, ['Could not determine gaps in SCA1B data ...' ...
        'in find_SCA1B_gaps. Skipping day... '], datestr(timeGPS2dt(SCA1B(1,1)))))

    return
end

%--- Compile output array
if twoMode == 1
    temp = ACC_B; 
    ACC_B = [ACC_B(:,1) ACC_B(:,4:end)]; ACCBtimeyz = temp(:,2:3); 
    output = [lon, lat, ACC_A, ACC_B, POS_A_SRF(:,2:end), POS_B_SRF(:,4:end), ind_SCA1B_gaps,  ACCBtimeyz]; 

else
    output = [lon, lat, ACC_A, ACC_B, POS_A_SRF(:,2:end), POS_B_SRF(:,2:end), ind_SCA1B_gaps]; 
end

%--- Finding indicies of padded output which corresponds to processing day
ACC_B((ACC_B(:,1) - ACCDateEpochs(1)) < 0, 1) = NaN;   % Setting time-tags before requested Date to NaN
ACC_A((ACC_A(:,1) - ACCDateEpochs(2)) > 0, 1) = NaN;   % Setting time-tags after requested Date to NaN
[~, ind1] = min(ACC_B(:,1) - ACCDateEpochs(1));        % Finding closest time-tag to requested Date in Date
[~, ind2] = min(abs((ACC_A(:,1) - ACCDateEpochs(2)))); % Makes output continuous and without boundary effects

%--- Isolating output to time stamp for Date without padding 
output = output(ind1-1:ind2,:);

%--- Downsampling to 1Hz if 10Hz to make more manageable
if isequal(inputs.Interpolate_ACC,1) || strcmpi(ACCprod, 'ACT1A')
    output = downsample(output, 10); 
end


%--- Outputting table and labelling columns for readability
if twoMode == 1
    output = array2table(output, 'VariableNames', {'Lon', 'Lat', 'timeGPSa', ...
    'ACCax', 'ACCay', 'ACCaz', 'timeGPSb', 'ACCbx', 'ACCby', 'ACCbz' ...
    'POSax', 'POSay', 'POSaz', 'POSbx', 'POSby', 'POSbz', 'SCA1B_gaps', 'timeGPSby', 'timeGPSbz'});
else

output = array2table(output, 'VariableNames', {'Lon', 'Lat', 'timeGPSa', ...
    'ACCax', 'ACCay', 'ACCaz', 'timeGPSb', 'ACCbx', 'ACCby', 'ACCbz' ...
    'POSax', 'POSay', 'POSaz', 'POSbx', 'POSby', 'POSbz', 'SCA1B_gaps'}); 
end
end

% %%
% %--- Load in thruster data
% THR1B_C = read_THR1B("C", Date, inputs(1).Path1B); 
% THR1B_C = THR1B_C.timeGPS;
% THR1B_D = read_THR1B("D", Date, inputs(1).Path1B); 
% THR1B_D = THR1B_D.timeGPS; 
% 
% %--- Get Thruster C data 
% POS = read_GNV1B_ITRF("C", Date, inputs(1).Path1B, 'pad', 2); 
% POS = interp_spline(POS, THR1B_C-24.1); 
% [lat, lon] = ecef2geodetic(wgs84Ellipsoid('meter'), POS(:,2), POS(:,3), POS(:,4));
% THRUSTc = [lon, lat, ones([length(lon), 1])]; 
% 
% %--- Get Thruster D data 
% POS = read_GNV1B_ITRF("D", Date, inputs(1).Path1B, 'pad', 2); 
% POS = interp_spline(POS, THR1B_D-24.1); 
% [lat, lon] = ecef2geodetic(wgs84Ellipsoid('meter'), POS(:,2), POS(:,3), POS(:,4));
% THRUSTD = [lon, lat, ones([length(lon), 1])]; 
% 
% N = length(output); 
% THRUSTc = padarray(THRUSTc, [N-length(THRUSTc), 0], 'post'); 
% THRUSTD = padarray(THRUSTD, [N-length(THRUSTD), 0], 'post'); 
% 
% output = [output, THRUSTc, THRUSTD]; 