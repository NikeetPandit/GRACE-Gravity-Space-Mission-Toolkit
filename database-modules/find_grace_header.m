function skip_rows = find_grace_header(fid)
% FIND_GRACE_HEADER Finds 'END OF HEADER' in GRACE data product.
%
%  Inputs:
%  (1) fid: File Identifier.
%
%  Example: fil_grace_header(fopen('file_to_read'))
%
%  Outputs:
%  (1) Row of header.
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

skip_rows = 0; 

while 1
    line = fgetl(fid);
    skip_rows = skip_rows + 1; 
    if contains(line,'END OF HEADER')
        break
    end
    if skip_rows == 1e9 % Debug check to prevent inf. evaluation 
        error("Cannot find end of header in file.")
    end
end
end