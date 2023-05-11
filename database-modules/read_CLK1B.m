function data = read_CLK1B(ID, Date, Path, varargin)
% read_CLK1B provides the offset to convert receiver time to GPS time. 
%   GPS time = timeREC + clockOFFSET. 
%
%   Function is called under-the-hood to map ACT1A data provided in
%   receiver time to GPS time. See timeOBC2GPS function. 
%
%   Inputs:
%   (1) ID:   "C" or "D" for GRACE-ID
%   (2) Date: Datetime object specifying date. 
%   (3) Path: String carrying location of all data products. 
%
%   Optional: 'pad'. followed by hours to pad before/after requested Date.
%                                          See truncate_data2pad function.
%
%   Example: read_CLK1B("C", datetime(2020, 1, 1), 'C:\files', 'pad', 3)
%            Pads 3 hours before/after after Jan 1, 2020 data product. 
%
%   Outputs:
%   (1)  data: Returned as [Receiver Time, Clock offset] 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

if isempty(varargin) 
    
    %--- Debug Check 
    if ~isequal(ID, "C") && ~isequal(ID, "D")
        error("Invalid GRACE-FO ID. Try again."); 
    end
    
    %--- Converting datetime obj to day 
    day = datestr(Date, 'yyyy-mm-dd'); 
    
    %--- Concatenate strings for file read
    file = strcat(Path, "\", "CLK1B_", day, "_", ID, "_", "04.txt");
    
    %--- Open file
    fid = fopen(file, 'r');
    
    %--- Find end of header
    skip_rows = find_gracefo_header(fid); frewind(fid); %resets pointer
    
    %--- read in file 
    data = cell2mat(textscan(fid, '%f %*c %*f %f %*[^\n]\n', 'HeaderLines', skip_rows, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', 0));
    
    %--- Isolate non-repeated elements 
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
            data{i} = read_CLK1B(ID, Date + days(i-2), Path); 
        end
    
    %--- Truncating data to padding amount specified
        data = truncate_data2pad(data, varargin); 
        [~, ind] = unique(data(:,1), 'stable'); data = data(ind,:); 

    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        data = read_CLK1B(ID, Date, Path); 
    end
    
end

end



