function [MonthStart, MonthEnd] = get_dates(DateStart, DateEnd)
% get_dates is called to to facilatate monthly, parallel processing 
%   in the GRACE level 1 processing toolbox. 
%
%   Where for each month, daily solutions are processed in parallel. After
%   the whole month is calculated, the calculations are saved to storage.
%   This was determined to be the fastest method of computation based on
%   experimentation. 
%   
%   Inputs: 
%   (1): Date0: initial date (Y,M,D). Datetime object. 
%   (2): n: Amount of months. Integer. 
%
%   Outputs:
%   (1): MonthStart: Datetime array
%   (2): MonthEnd:   Datetime array
% 
%   Example: 
%   [MonthStart, MonthEnd] = getdates(datetime(2010,1,10), datetime(2010, 3, 1)
%   DateStart = '10-Jan-2010'	'01-Feb-2010'	'01-Mar-2010'
%   DateEnd   = '31-Jan-2010'	'28-Feb-2010'	'31-Mar-2010'
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug check 
if DateEnd < DateStart
    error("End date must come after start date."); 
end

%--- Isolating year/month from inputs
[y, m] = ymd(DateStart); [y1, m1] = ymd(DateEnd); 

%--- Compiling output
if      isequal(m, m1) && isequal(y, y1)
    MonthStart = DateStart; 
    MonthEnd = DateEnd; 

else
MonthStart = cat(2, DateStart, datetime(y, m, 1) + calmonths(1:(m1 - m) + 12*(y1 - y))); 
MonthEnd = cat(2, datetime(y, m, 1) + calmonths(1) - 1, ...
    MonthStart(1,2:end - 1) + calmonths(1) - days(1), DateEnd); 
    
end
end