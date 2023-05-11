function inputs =  setGRACEfolder(inputs)
%Function sets input 1b folder for GRACE data since data files are held in
%   different locations
%   
%   Inputs:
%   (1): Structure with arbitrary 1B folder
%
%   Outputs:
%   (1): Structure with actual 1B folder
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com 
%
%------------------------------------------------------------------------------------------------------------------

try
    Date = inputs.Processing_Day; 
catch
    Date = inputs; 
end

%--- Determine GRACE mission
mission = det_GRACEmission(Date); 
if      isequal(mission, 'GRACE')

    folder1 = [datetime(2004, 1, 1), datetime(2009, 12, 31)]; 
    folder2 = [datetime(2010, 1, 1), datetime(2010, 12, 31)]; 
    folder3 = [datetime(2011, 1, 1), datetime(2017, 6, 29)]; 


    if      isbetween(Date, folder1(1), folder1(2))
        inputs.Path1B = 'E:\DATA-PRODUCTS\GRACE-Data\GRACE-2004-2009';
    
    elseif  isbetween(Date, folder2(1), folder2(2))
        inputs.Path1B = 'E:\DATA-PRODUCTS\GRACE-Data\GRACE-2010';

    elseif isbetween(Date, folder3(1), folder3(2))
        inputs.Path1B = 'E:\DATA-PRODUCTS\GRACE-Data\GRACE-2011-2017';

    else
        error("Specified date is not within GRACE data range."); 
    end
    inputs.Path1A = []; 
    
    
 
elseif  isequal(mission, 'GRACE_FO') 
    return; 

else
    error("Mission should correspond to GRACE or GRACE-FO")

end
