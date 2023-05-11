function [data, ind] = read_ACC1B(ID, Date, Path, varargin)
% read_ACC1B reads in ACC1B linear accelerations for GRACE. Applies
%   calibration and scaling factors. See calib_ACC function.
%   
%   Inputs:
%   (1) ID:   "A" or "B" GRACE identifier. 
%   (2) Date: Datetime object specifying date. 
%   (3) Path: String carrying location of all data products.
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_ACC1B("C", datetime(2010, 1, 1), 'C:\files', 'pad', 3)
%
%   Outputs:
%   (1) data: Returned as [timeGPS, ACC_X, ACC_Y, ACC_Z]
%   (2) ind: [Start Index, End Index] for data of date requested in output (1)
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

ind = [];
%--- Debug Check 
if ~isequal(ID, "A") && ~isequal(ID, "B")
    error("Invalid GRACE ID. Try again.");
end

%--- Setting varargin to empty if padding is 0
if ~isempty(varargin) && varargin{2} == 0
    varargin = []; 
end

if isempty(varargin) 

    %--- Converting datetime obj to day 
    daystr = datestr(Date, 'yyyy-mm-dd'); 
    
    %--- Concatenate strings for file read
    file = strcat(Path, "\", "ACC1B_", daystr, "_", ID, "_", "02.dat");
    
    %--- Open file
    fid = fopen(file, 'r');
    
    %--- Find end of header
    skip_rows = find_grace_header(fid); frewind(fid); %resets pointer
  
    %--- Read in file 
    data = cell2mat(textscan(fid, '%f %*s %f %f %f %*[^\n]\n', 'HeaderLines', skip_rows, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', 0));
    
    %--- Close file
    fclose(fid);

    %--- Calibrate ACC1B data
    if ~isempty(data)
        data = calib_ACC(data, ID);
    end

else
    try
        data = cell([1, 3]);
    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_ACC1B(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
        [data, ind] = truncate_data2pad(data, varargin); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_ACC1B(ID, Date, Path); 
    end
    
end
end



