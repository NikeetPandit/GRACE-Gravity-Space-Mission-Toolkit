function THR1B = read_THR1B(ID, Date, Path, varargin)
% read_THR1B loads in commanded thruster on-times in seconds. 
%   See GRACE-FO L1 handbook. Output data is structure. 
%
%   "Ctrl": roll (r), pitch (p), yaw(y) 
%   "Sign": positive (p), negative (n)
%   "Ptg" Firing direction: X, Y, Z in SRF
%
%   %--- Branch 1
%   THR1B.timeGPS = data(:,1) + data(:,2) * 1e-6; 
%   THR1B.Ctrl1_yn_Ptg_yn = data(:,3); 
%   THR1B.Ctrl1_pp_Ptg_zn = data(:,4); 
%   THR1B.Ctrl1_yp_Ptg_yp = data(:,5); 
%   THR1B.Ctrl1_pn_Ptg_zp = data(:,6); 
%   THR1B.Ctrl1_rn_Ptg_yn = data(:,7); 
%   THR1B.Ctrl1_rp_Ptg_yn = data(:,8); 
% 
%   %--- Branch 2
%   THR1B.Ctrl2_yn_Ptg_yp = data(:,9); 
%   THR1B.Ctrl2_pp_Ptg_zp = data(:,10); 
%   THR1B.Ctrl2_yp_Ptg_yn = data(:,11); 
%   THR1B.Ctrl2_pn_Ptg_zn = data(:,12); 
%   THR1B.Ctrl2_rn_Ptg_yp = data(:,13); 
%   THR1B.Ctrl2_rp_Ptg_yp = data(:,14); 
% 
%   %--- Orbit Cntrl
%   THR1B.OCtrl_dV_Ptg_xn = data(:,15); 
%   THR1B.OCtrl_dV_Ptg_xn = data(:,16); 
%
%   Inputs:
%   (1) ID:   "A", "B", "C" or "D" for GRACE and GRACE-FO ID. 
%   (2) Date: Specifying date of data product to load. Type Datime. Size 1. 
%   (3) Path: String carrying location of data product. 
%
%   Example: read_THR1B("C", datetime(2020, 1, 1), 'C:\files')
%
%   Outputs:
%   (1) THR1B (type structure). See above
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
    file = strcat(Path, "\", "THR1B_", day, "_", ID, "_", "02.dat");    

elseif any(strcmpi(ID, ["C", "D"]))
    GRACE = 0; 
    file = strcat(Path, "\", "THR1B_", day, "_", ID, "_", "04.txt");

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

%--- Format columns to read in
skip_cols = repmat("%*f ", [1, 14]); 
incl_cols = repmat("%f ", [1 14]); 
fileformat = join(["%f %f %*c %*c", join([skip_cols, incl_cols]), "%*[^\n]\n"]);

%--- Read in file 
data = cell2mat(textscan(fid, fileformat, "HeaderLines", skip_rows, "Delimiter", " ", "MultipleDelimsAsOne", true, "ReturnOnError", 0));

%--- Close file
fclose(fid);

%--- Assign data to struct
THR1B.timeGPS = data(:,1) + data(:,2) * 1e-6; 
THR1B.data = data(:,3:end);     
THR1B.CtrlLabels = ["Y-", "P+", "Y+", "P-", "R-", "R+", "Y-", "Y-", "P+", "Y+", "P-", "R-", "R+", "Y-, dV, dV"]; 
%THR1B.CtrlPlotLabels = ["rv", "g^", "r^", "gv", "bv", "b^", "rv", "rv", "g^", "r^", "gv", "bv", "b^", "rv", "bx", "bx"]; 
THR1B.PtgLabels = ["-Y", "-Z", "+Y", "+Z", "-Y", "-Y", "+Y", "+Z", "-Y", "-Z", "+Y", "+Y", "-X", "-X"]; 


else
    try
        data = cell([1, 3]);

    % --- Padding requested date before and after
        for i = 1:3
            data{i} = read_THR1B(ID, Date + days(i-2), Path); 
        end
        THR1B = []; 
        for i = 1:3
            THR1B = cat(1, THR1B, [data{1,i}.timeGPS]); 
        end
                   
    
    %--- See warning message below
    catch
        warning("Unpadded data is returned due to missing data."); 
        THR1B = read_THR1B(ID, Date, Path); 
    end
    
end        

end



