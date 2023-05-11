function  [data, ind] = read_GNI1B_IRF(ID, Date, Path, varargin)
% read_GNI1B_IRF reads in 1-Hz position states from POD in IRF (Inertial, Earth-centred).
%
%   For GRACE-FO, this is provided in the GNI1B data product. For GRACE, the
%   position states are only provided in ITRF. Hence, when this function is
%   called and a GRACE ID is selected, the GNV1B data producted in ITRF is
%   read in. Thereafter, ITRFtoIRF (see function) is called to rotate the
%   data to IRF, and this transformed data is returned. Valid for position
%   transformations only.
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product. 
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_GNI1B_IRF("C", datetime(2010, 1, 1), 'C:\files', 'pad', 3)
%
%   Outputs:
%   (1) data: [timeGPS, POS_X, POS_Y, POS_Z]. Size [nx4]. 
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
        %file = strcat(Path, "\", "GNV1B_", day, "_", ID, "_", "02.dat"); 
        file = strcat('F:\DATA-PRODUCTS\GNI1B_GRACE\', "GNI1B_", day, "_", ID, "_", "02.mat");
    
    elseif any(strcmpi(ID, ["C", "D"]))
        GRACE = 0; 
        file = strcat(Path, "\", "GNI1B_", day, "_", ID, "_", "04.txt");
    
    else
        error("Invalid GRACE or GRACE-FO ID. Try again.");
    end
    
    %--- Open file
    if GRACE == 0
        fid = fopen(file, 'r');
        
        %--- Find end of header
        if isequal(GRACE, 1)
            skip_rows = find_grace_header(fid); frewind(fid); % Resets pointer
        else
            skip_rows = find_gracefo_header(fid); frewind(fid); % Resets pointer
        end
        
        %--- Read in file 
        data = cell2mat(textscan(fid, '%f %*c %*c %f %f %f %*f %*f %*f %*[^\n]\n', 'HeaderLines', skip_rows, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', 0));
    
        %--- Rotating to IRF if GRACE ID is selected
        if isequal(GRACE, 1)
            data = ITRFtoIRF(data); 
        end
        
        %--- Close file
        fclose(fid);
    else
        data = load(file).DataOut; 
    end
    
else
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_GNI1B_IRF(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
        [data, ind] = truncate_data2pad(data, varargin); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_GNI1B_IRF(ID, Date, Path); 
    end
    
end    

end