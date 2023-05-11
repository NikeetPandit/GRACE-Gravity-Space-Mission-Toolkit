function [data, ind] = read_ACT1A(ID, Date, PathA, PathB, varargin)
% READ_ACT1A reads in ACT1A linear accelerations for GRACE-FO. 
%
%   Routine returns ACT1A data in SRF and GPS time so it can be used. 
%   ACT1A by JPL nominally provides data AF and OBC time.
%
%   Inputs:
%   (1) ID:   "C" or "D" GRACE-FO identifier. 
%   (2) Date: Datetime object specifying date. 
%   (3) PathA: String carrying location of all data 1A products. 
%   (3) PathB: String carrying location of all data 1B products. 
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%          Must be in range (1, 23). See truncate_data2pad function. 
%
%   Example: read_ACT1A("C", datetime(2020, 1, 1), 'C:\files', 'pad', 3)
%            Pads 3 hours before/after after Jan 1, 2020 data product. 
%
%   Outputs:
%   (1) data: [timeGPS, ACC_X_SRF, ACC_Y_SRF, ACC_Z_SRF]. Size [nx4]. 
%   (2) ind:  [Start Index, End Index] for data of Date requested in output (1). Size [1x2]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------
 
ind = [];
%--- Input Check 
if ~isequal(ID, "C") && ~isequal(ID, "D")
    error("Invalid GRACE-FO ID. Try again."); 
end

%--- Setting varargin to empty if padding is 0
if ~isempty(varargin) && varargin{2} == 0
    varargin = []; 
end

if isempty(varargin) 

%--- Converting datetime obj to day 
day = datestr(Date, 'yyyy-mm-dd'); 

%--- Concatenate strings for file read
file = strcat(PathA, "\", "ACT1A_", day, "_", ID, "_", "04.txt");

%--- Open file
fid = fopen(file, 'r');

%--- Find end of header
skip_rows = find_gracefo_header(fid); frewind(fid); %resets pointer

%--- Read in file 
data = cell2mat(textscan(fid, '%f %f %*c %*c %*s %*f %f %f %f %*[^\n]\n', 'HeaderLines', skip_rows, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', 0));

%--- Converting microseconds to seconds
data = [data(:,1) + data(:,2) * 1e-6, data(:,3:end)]; 

%---Transforming from AF to SRF 
temp = data; data(:,2) = temp(:,4); data(:,3) = temp(:,2); data(:,4) = temp(:,3); 

%--- Mapping ACT1A data stamped in REC time to GPS time 
data(:,1) = timeOBC2GPS(data(:,1), ID, Date, PathB); 

%--- Close file
fclose(fid);

else
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_ACT1A(ID, Date + days(i-2), PathA, PathB); 
        end
    
    %--- Truncating data to padding amount specified
        [data, ind] = truncate_data2pad(data, varargin); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_ACT1A(ID, Date, PathA, PathB); 
    end
    
end
end



