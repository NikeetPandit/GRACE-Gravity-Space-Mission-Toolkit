function timeGPS = timeOBC2GPS(timeOBC, ID, Date, Path)
% TIMEOBC2GPS maps a time array in OBC time to GPS time using CLK1B and
%   TIM1B data products. Assumes linear drift. Necessary for ACT1A data
%   which is provided in OBC time (either C, or D). Not needed for GRACE
%   since 1A data is not provided. See GRACE_FO L1 handbook.
%
%   Function is called under-the-hood when read_ACT1A function is called. 
%
%   Inputs:
%   (1) timeOBC: Type double. Size [nx1].
%   (2) ID:      "C" or "D" GRACE-FO identifier. 
%   (3) Date:    Datetime object specifying date. 
%   (4) Path:    String carrying location of all data products. 
%
%   Outputs:
%   (1) timeGPS: Type double. Size [nx1].
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
if ~isequal(ID, "C") && ~isequal(ID, "D")
    error("Invalid GRACE-FO ID. Try again."); 
end

%--- Reading in OBC to REC time mapping product
TIM1B = read_TIM1B(ID, Date, Path, 'pad', 3);

%--- Interpolate TIM1B to parsed OBC time array
timeREC = interp1(TIM1B(:,1), TIM1B(:,2), timeOBC, 'linear'); 

%--- Read in clock offset to convert REC time to GPS time 
CLK1B = read_CLK1B(ID, Date, Path, 'pad', 3);

%--- Interpolate time offsets to receiver time array
timeOFFSET = interp1(CLK1B(:,1), CLK1B(:,2), timeREC, 'linear'); 

%--- GPS time = timeREC + clockOFFSET 
timeGPS = timeREC + timeOFFSET; % Returns GPS time array

end
