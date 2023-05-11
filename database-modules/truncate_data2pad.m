function [dataOut, ind] = truncate_data2pad(dataIn, varargin)
% truncate_data2pad accepts 1x3 cell of data and truncates it based on user
%   specification.
%
%   A motiviation for the development of this routine is as follows:
%   It is desired to filter 1 day of GRACE linear acceleration data. In
%   the convolution process, the edges of the day of data loaded to be
%   filtered will be corruped by incomplete convolution. Therefore, by padding
%   sufficiently extra data before and after the requested date to be loaded 
%   in, we do not observe this boundary effect. 
% 
%   This routine is called under-the-hood to truncate the data based on 
%   a user selected amount of padding before and after, some requested
%   date of data to be loaded in.
%
%   Inputs:
%   (1) dataIn: {Date Before, Date Requested, Date After}. Type cell. Size [1x3]. 
%       Each cell inside must be inputted as [time, X, Y, Z] and of type double. 
%
%   (2) 'pad' followed by integer specifying padding in hours in range (1, 23). 
%       Default is assumed as 1. 
%
%   Outputs:
%   (1) dataOut: [time, X, Y, Z]. Type double. Size [nx4].
%   (2) ind:  [Start Index, End Index] for data of Date requested. Size [1x2]. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
if ~isequal(class(dataIn), 'cell') || ~isequal(size(dataIn), [1, 3])
    error("Dimensions of input data not correct. See documentation.");
end

%--- Reading in variable input
varargin = varargin{1}; ind = find(strcmpi(varargin, 'pad')); 
if ~isempty(ind)
    try
        pad_amnt = round(varargin{ind + 1}); 
    catch
        pad_amnt = 1; % Assigning 1 hour pad by default
    end
else
    warning("This function should not be called. Nothing computed."); 
    return; 
end

%--- Debug Check 2
if pad_amnt < 1 || pad_amnt > 23
    error("Specified padding amount is out of bounds."); 
end

%--- Isolating time vector from data
t = dataIn{2}(:,1); 

%--- Average sample rate in hours
M = round(avg_sample_rate(t)*3600) * pad_amnt; 

%--- Isolation based on padding adjusted to sample rate
dataIn{1} = dataIn{1}(end-M + 1:end, :); 
dataIn{3} = dataIn{3}(1:M, :); temp = dataIn{2}; 

%--- Compilation of Array
dataOut = [dataIn{1}; dataIn{2}; dataIn{3}];

%--- Get unique data (sometimes repeated)
[~, ind] = unique(dataOut(:,1), 'stable'); dataOut = dataOut(ind,:); 

%--- Determing indicies asssociated to unpadded data
ind = [find(dataOut(:,1) == temp(1,1)), find(dataOut(:,1) == temp(end,1))]; 

end