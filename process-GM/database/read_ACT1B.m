function [data, ind] = read_ACT1B(ID, Date, Path, varargin)
% read_ACT1B reads in ACT1B linear accelerations for GRACE-FO. 
%   
%   Inputs:
%   (1) ID:   "C" or "D" GRACE-FO identifier. 
%   (2) Date: Datetime object specifying date. 
%   (3) Path: String carrying location of all data products.
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_ACT1B("C", datetime(2020, 1, 1), 'C:\files', 'pad', 3)
%
%   Outputs:
%   (1) data: [timeGPS, ACC_X, ACC_Y, ACC_Z]. Size [nx4]. 
%   (2) ind:  [Start Index, End Index] for data of Date requested in output (1). Size [1x2]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

ind = [];
%--- Debug Check 
if ~isequal(ID, "C") && ~isequal(ID, "D")
    error("Invalid GRACE-FO ID. Try again.");
end

%--- Setting varargin to empty if padding is 0
if ~isempty(varargin) && varargin{2} == 0
    varargin = []; 
end

if isempty(varargin) 

    %--- Converting datetime obj to day 
    daystr = datestr(Date, 'yyyy-mm-dd'); 
    
    %--- Concatenate strings for file read
    file = strcat(Path, "\", "ACT1B_", daystr, "_", ID, "_", "04.txt");
    
    %--- Open file
    fid = fopen(file, 'r');
    
    %--- Find end of header
    skip_rows = find_gracefo_header(fid); frewind(fid); %resets pointer
  
    %--- Read in file 
    data = cell2mat(textscan(fid, '%f %*s %f %f %f %*[^\n]\n', 'HeaderLines', skip_rows, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', 0));
    
    %--- Close file
    fclose(fid);

else
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_ACT1B(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
        [data, ind] = truncate_data2pad(data, varargin); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_ACT1B(ID, Date, Path); 
    end
    
end
end



