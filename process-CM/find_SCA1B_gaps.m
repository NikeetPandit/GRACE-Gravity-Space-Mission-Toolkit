function Logic_Array = find_SCA1B_gaps(Mode, PathData, TimeTag, varargin)
% Finds_SCA1B_gaps accepts time-tag of interpolated SCA1B data. It returns 
%   the indicies where parsed SCA1B data was interpolated using data that
%   has gaps larger than 5 seconds. 
%   
%   The motiviation of this routine stems from the fact that the
%   attitude determination given in the SCA1B data is critical 
%   for the gradiometer concept. Therefore, this routine allows gradient
%   measurements, which have been determined using unduly interpolation,
%   and are thus unreliable attitude information  - to be removed. This is a
%   processing step to ensure more reliable gradient measurements. 
%
%   Inputs:
%   (1) Mode, either 1 or 2, to represent 1 or 2 mode gradient operation. 
%   (2) Path: String carrying location of data product. 
%   (3) TimeTag: Time-tag of interpolated SCA1B data. Size [nxm]. 
%       [TimeTag1, TimeTag2, ... TimeTagyM]. 
%       
%       TimeTag must be in GPS time and correspond to one "Date" of
%       measurements with at most 3 hours of padding on either side!
%
%       For motivation behind why m>1, see minDistSRF_xyz function. 
%
%   Optional: 'ID': ID of SCA1B data parsed in, if 1 mode is selected.       
% 
%   Outputs:
%   (1)  Logical_Array: Denotes 1 for SCA1B data gap larger than 5 seconds
%        for input (3).  Size [nx1]. Associated to the calculated
%        intersection of all inputs time tags, input (3). 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

%--- Debug Check 
%--- Find the Date that is requested without the padding 
[y, m, d] = ymd(mean(timeGPS2dt(TimeTag))); 
Date = datetime(y, m, d); % build a datetime object

%--- See if padding on either side of requested date > 3 hours 
first_timetag = abs(timeGPS2dt(TimeTag(1,1)) - Date) > hours(3.5); 
last_timetag = abs(timeGPS2dt(TimeTag(end,1)) - (Date + days(1) - seconds(1))) > hours(3.5);

%--- Throw error if previous condition is met
if first_timetag + last_timetag > 0
    error("Parsed time-tag is out of bounds of allowable limits. See function for more details."); 
end

%--- Find the gaps in the SCA1B data which are greater than 10 seconds
switch Mode 
    %--- One mode gradient operation 
    case 2

        %--- Reading in SCA1B data for both A, B, C, D
        try
            SCA1B_A = read_SCA1B("A", Date, PathData, 'pad', 6);  % GRACE is selected
            SCA1B_B = read_SCA1B("B", Date, PathData, 'pad', 6); 
        catch
            SCA1B_A = read_SCA1B("C", Date, PathData, 'pad', 6);  % GRACE_FO is selected
            SCA1B_B = read_SCA1B("D", Date, PathData, 'pad', 6);   
        end
        
        %--- Finding gaps in SCA1B data using time stamps
        A_gaps = get_SCA1B_gaps(SCA1B_A(:,1)); % See in-line function 
        B_gaps = get_SCA1B_gaps(SCA1B_B(:,1)); 
        
        %--- Concatenating along 1 both gap times
        SCA1B_GapTimes = cat(1, A_gaps, B_gaps); 
        
    case 1
        
        %--- Debug check 
        if isequal(length(varargin), 0)
            error("Must input ID for one mode operation"); 
        end

        %--- Assigning variable input ID
        ID = varargin{1}; 
        
        %--- Reading in SCA1B data for ID
        SCA1B = read_SCA1B(ID, Date, PathData, 'pad', 6);

        %--- Finding gaps in SCA1B data using time stamps
        SCA1B_GapTimes = get_SCA1B_gaps(SCA1B(:,1)); % See in-line function 

    otherwise
        error("Mode has not been selected"); 
end
 

[~, m] = size(TimeTag); 


for i = 1:m
    ind_cell{i} = find_no_gap_SCA1B_nested(SCA1B_GapTimes, TimeTag(:,i)); 
end

Logic_Array = logical(max(cell2mat(ind_cell), [], 2)); 

end

%% ----------------------------------------------------------------------------------------------------------------
function ind_logic = find_no_gap_SCA1B_nested(SCA1B_GapTimes, TimeArray)

%--- Finding which indicies in the inputted time array correspond to the range of the SCA1B gap times
ind = []; 
[n, ~] = size(SCA1B_GapTimes); 
for i = 1:n
    ind =  cat(1, ind, find(TimeArray(:,1) >= SCA1B_GapTimes(i,1) & TimeArray(:,1) <= SCA1B_GapTimes(i,2))); 
end

%--- Finding the set excusive OR of the indicies above and all the indicies associated to the input time array
ind = setxor(ind, 1:length(TimeArray)); % Its output is then the indicies of the time array which include data without gaps

%--- Turn indicies to logical vector
ind_logic = ones([length(TimeArray) 1]); 
ind_logic(ind) = 0; 

end

%% ----------------------------------------------------------------------------------------------------------------
%--- Finding the gaps in the SCA1B data which are larger than 5 seconds
function SCA1B_gap_times = get_SCA1B_gaps(time)

%--- Simple foreward difference
gap_ind = find(diff(time) > 5);

%--- Finding the correct index where the gap starts by adding 1
gap_ind = [gap_ind gap_ind + 1]; 

%--- Finding the gaps of the time array
SCA1B_gap_times = time(gap_ind); 

%--- Just so shape of the output is how function interprets it (see header documentation)

if length(SCA1B_gap_times) == 2
    SCA1B_gap_times = SCA1B_gap_times'; 
end

end






