function  [data, ind] = read_KBR1B(ID, Date, Path, varargin)
% read_KRB1B reads in corrected range seperation for GRACE missions.  
%   r_calibrated = r_measured + light_correction + antenna_correction.
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product. 
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_KBR1B("C", datetime(2020, 1, 1), 'C:\files', 'pad', 3)
%
%   Outputs:
%   (1) data: [timeGPS, corrected bias range in meters]. Size [nx2]. 
%   (2) ind:  [Start Index, End Index] for data of Date requested in output (1). Size [1x2]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

if isempty(varargin) 

    %--- Converting datetime obj to day 
    day = datestr(Date, 'yyyy-mm-dd'); 
    
    %--- Concatenate strings for file read
    
    if     any(strcmpi(ID, ["A", "B"]))
        GRACE = 1; % Logical array to denote GRACE mission
        file = strcat(Path, "\", "KBR1B_", day, "_","X", "_", "02.dat");    
    
    elseif any(strcmpi(ID, ["C", "D"]))
        GRACE = 0; 
        file = strcat(Path, "\", "KBR1B_", day, "_", "Y", "_", "04.txt");
    
    else
        error("Invalid GRACE or GRACE-FO ID. Try again.");
    end
    
    %--- Open file
    fid = fopen(file, 'r');
    
    %--- Find end of header
    if isequal(GRACE, 1)
        skip_rows = find_grace_header(fid); frewind(fid); % Resets pointer
    else
        skip_rows = find_gracefo_header(fid); frewind(fid); % Resets pointer
    end
    
    %--- Read in file 
    data = cell2mat(textscan(fid, '%f %f %*f %*f %*f %f %*f %*f %f %*[^\n]\n',  'HeaderLine', skip_rows, 'delimiter', ' ', 'ReturnOnError', 0));

    %--- Corrected biased range = biased range + light time correction + antenna offset correction 
    data(:,2) = sum(data(:,2:end), 2); data = data(:,1:2); 
    
    %--- Close file
    fclose(fid);

else
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_KBR1B(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
        [data, ind] = truncate_data2pad(data, varargin); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_KBR1B(ID, Date, Path); 
    end
    
end    
end