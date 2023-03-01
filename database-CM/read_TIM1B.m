function data = read_TIM1B(ID, Date, Path, varargin)
% READ_TIM1B provides mappings OBC to receiver time. 
%
%   Function is called under-the-hood to map ACT1A data provided in
%   receiver time to GPS time. See timeOBC2GPS function. 
%
%   Inputs:
%   (1) ID:   "C" or "D" GRACE-FO identifier. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product. 
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_TIM1B("C", datetime(2020, 1, 1), 'C:\files', 'pad', 3)
%
%   Outputs:
%   (1)  data: [OBC Time, Receiver Time]. Type double. Size [nx2]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------
 
%--- Debug Check 
if ~isequal(ID, "C") && ~isequal(ID, "D")
    error("Invalid GRACE-FO ID. Try again."); 
end

if isempty(varargin) 

    %--- Converting datetime obj to day 
    day = datestr(Date, 'yyyy-mm-dd'); 
    
    %--- Concatenate strings for file read
    file = strcat(Path, "\", "TIM1B_", day, "_", ID, "_", "04.txt");
    
    %--- Open file
    fid = fopen(file, 'r');
    
    %--- Find end of header
    skip_rows = find_gracefo_header(fid);
    frewind(fid); %resets pointer
    
    %--- Read in file 
    data = cell2mat(textscan(fid, '%f %*c %*f %f %f %*[^\n]\n', 'HeaderLines', skip_rows, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', 0));
    
    %--- Converting fractional part to nanoseconds
    data(:,2) = data(:,2) + data(:,3)*1e-9; data(:,3) = []; 
    
    %--- Get unique data (sometimes repeated)
    [~, ind] = unique(data(:,1), 'stable'); data = data(ind,:); 
    
    %--- If mapping is equal to 0 (i.e., undefined) remove
    ind = data(:,2) == 0; data(ind, 2) = NaN; data = rmmissing(data); 
    
    %--- Close file
    fclose(fid);

else    
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_TIM1B(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
        data = truncate_data2pad(data, varargin); 
        [~, ind] = unique(data(:,1), 'stable'); data = data(ind,:); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to invalid padding selection or unavailable data product before or after requested data."); 
        data = read_TIM1B(ID, Date, Path); 
    end
    
end
end
