function [DateStart, DateEnd] = get_dates(Date0, n)
%GET_DATES is a simple utility to which gets called to facilatate monthly
%   gradient solution determination. 
%   
%   Inputs: 
%   (1): Date0, datetime object, ONE initial date (Y,M,D) 
%   (2): n, integer, specifying amount of months 
%
%   Outputs:
%   (1): DateStart, datetime array, "Start Dates"
%   (2): DateEnd, datetime array, "End Dates"
% 
%   Example: 
%   [DateStart, DateEnd] = getdates(datetime(2010,1,1), 3)
%   DateStart = '01-Jan-2010'	'01-Feb-2010'	'01-Mar-2010'
%   DateEnd   = '31-Jan-2010'	'28-Feb-2010'	'31-Mar-2010'
%
%   The utility is called to create monthly solutions for any given date range. 
%   For each month, a daily solution is constructed. After all the daily calculations have been
%   calculated, the daily output result is loaded into ram. Then, the next daily
%   solution is constructed. This is done in parallel by default, so you
%   actually have X number of daily gradient solutions being computed simaltaneously,
%   depending on the amount of cores on your system. Once one month of
%   solutions has been computed, the result is then outputed in a .mat
%   file. Then, the next monthly solutions is computed and etc.
% 
%   There was some performance testing of writing each daily result,
%   vs. compiling the monthly results. From by brief testing, this
%   provided the best result. Computing daily solutions in parallel
%   provides significant performance improvements. If, for example, one was to try
%   and compute gradient solutions for 1 year before data was being written
%   out, you would get out of memory issues with too much data being loaded
%   into ram, or if your machine was capable of having all this data loaded
%   in, each process you are computting with an increasing amount of daily
%   solutions loaded in ram would become increasingly slower. So, there is
%   a fundamental trade-off. 
% 
%   On the other hand, if one was do 6 daily
%   solutions then write this out, you get also decreases in performances later on
%   coming from the fact that you need to read in way more files for a
%   yearly solution (for ex) vs 12 if you had outputted the 12 monthly .mat files
%   So, this utility allows me to do a monthly
%   solutions since it worked well for my machine, but this could be
%   improved on, and there likely is a fundamental point where there is
%   maximum efficiency when considering these trade-offs. 
%
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%Debug check 
if ~isequal(length(Date0), 1)
    error("Dimensions of input data not correct. See documentation"); 
end

if ~isequal(floor(n), n)
    error("Input n must be an integer"); 
end

for i = 0:n
    DateStart(i+1) = datetime(datestr((addtodate(datenum(Date0), i, 'month')))); 
end

for i = 1:n
    DateEnd(i) = datetime(datestr((addtodate(datenum(DateStart(i+1)), -1, 'day'))));
end

DateStart = DateStart(1:end-1);
end