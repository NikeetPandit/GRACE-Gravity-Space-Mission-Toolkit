function function_return = process_inputs(inputs_in)
warning('on', 'all');
    switch nargin 
        case 0
            function_return = struct('Working_Directory', {}, 'Path1A', {}, 'Path1B', {},  'GRACE_ID', {}, ...
                'Interpolate_ACC', {}, 'Use_ACCfromPOD', {},  'Filter_Type', ...
              {},   'Filter_Cut_Offs', {}, 'Filter_Order', {}, ...
              'Compute_Start_Date', {}, 'Compute_End_Date', {}, 'Path_Out', {}, 'Debug_Mode', {}, ...
              'Processing_Day', {}, 'Num_Of_Satellites', {}, 'GMshift', {}); 

        case 1
    
        %--- Determining if GRACE or GRACE-FO
        if      max(strcmpi(["C", "D"], inputs_in.GRACE_ID))
            GRACE = 0; 
        elseif  max(strcmpi(["A", "B"], inputs_in.GRACE_ID))
            GRACE = 1; 
        else
            error("Invalid GRACE or GRACE-FO ID."); 
        end
    
        %--- Throwing error messages if incorrect inputs are parsed
        
        if      isempty(inputs_in.Path1B)
            error("Must specifiy path of 1B GRACE and GRACE-FO data products."); 
    
        elseif  isempty(inputs_in.Working_Directory)
            error("Must specify current working directory.");
            
        elseif  ~isempty(inputs_in.Filter_Type) && isempty(inputs_in.Filter_Cut_Offs)
            error("Filtering type selected without any cut-off frequencies(s).");
        
        elseif isempty(inputs_in.GRACE_ID)
            error("Must specify GRACE or GRACE-FO identifier."); 
    
        elseif ~isempty(inputs_in.Path1A) && GRACE == 1
            error("Specifying 1A data path when a GRACE-ID is selected. 1A data is not released."); 

        elseif isempty(inputs_in.Compute_Start_Date) 
            error("Must specify computing start date."); 

        elseif ~isempty(inputs_in.Compute_End_Date) && inputs_in.Compute_Start_Date > inputs_in.Compute_End_Date
            error("End computing date cannot be before start computing date."); 
        
        elseif isempty(inputs_in.Num_Of_Satellites)
            error("Must specify number of satellites used for GRACE gradiometer mode."); 

        elseif ~isempty(inputs_in.GMshift) && isequal(strcmpi(inputs_in.GMshift, 'norm'), 0)
            error("GM shift must be empty (as to be evaulated by minimum approach in SRF) or set to norm"); 
        end

        %--- Checking to see if the input convention is correct
        check = fieldnames(process_inputs()); 
        ind = structfun(@isempty, inputs_in); 
        check_in = fieldnames(inputs_in); 
        check_in = check_in(~ind); 
        equil = 0; 
        for i = 1:length(check_in)
            for j = 1:length(check)
                equil = equil + isequal(check{j}, check_in{i}); 
            end
            if isequal(equil, 1)
               equil = 0; 
            else
                error("Incorrect parsing of inputs. Please ensure spelling matches the input structure convention exactly."); 
            end
        end

        if isempty(inputs_in.Filter_Cut_Offs) || isempty(inputs_in.Filter_Type)
            warning('No filtering is performed to accelerometer data... Proceeding anyway');
        end
   
        %--- Determining which acceleromter product must be used based on inputs
    
        if      isequal(inputs_in.Use_ACCfromPOD, 1)
            ACCprod = 'POD'; 
    
        elseif  ~isempty(inputs_in.Path1A)
            ACCprod = 'ACT1A'; 
        
        elseif  ~isempty(inputs_in.Path1B) && GRACE == 1
            ACCprod = 'ACC1B'; 
        
        elseif  ~isempty(inputs_in.Path1B)  && GRACE == 0
            ACCprod = 'ACT1B'; 
    
        else
            error("Could not determine which accelerometer data to use based on inputs."); 
        end

        function_return = ACCprod; 
        return; 

    end

end
 