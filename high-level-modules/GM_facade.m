function DataOut = GM_facade(inputs)

%--- Making folders to write out results if in computation mode
if ~isequal(inputs.Debug_Mode, 1)
    if isempty(inputs.Path_Out)
        error("Must specify path to output computations in input structure."); 
    end

    cd(inputs.Path_Out);
    mkdir(datestr(datetime, 'yyyy_mm_dd_hhMM')); 
    inputs.Path_Out = append(inputs.Path_Out, '\', datestr(datetime, 'yyyy_mm_dd_hhMM'), '\'); 
    cd(inputs.Path_Out); mkdir('Monthly_Sols'); cd(inputs.Working_Directory); 
end

%--- Determine if two spacecraft or one spacecraft is used for gradient calculation
if inputs.Num_Of_Satellites == 2
    SC = 2;
else
    SC = 1; 
end

%--- Setting bounds to compute monthy solutions ends
if ~isempty(inputs.Compute_End_Date)
    [DateStart, DateEnd] = get_dates(inputs.Compute_Start_Date, inputs.Compute_End_Date); 
else
    DateStart = inputs.Compute_Start_Date; DateEnd = DateStart; 
end

%--- Skipping days if data is corrupted based on flight logs
%SkipDays = rmmissing(readtable('skip-days.xlsx').Var1); % Can put a table to skip
SkipDays = datetime(1999,1,1);

%--- Running Software for DateRange
for j = 1:length(DateStart)

%--- Calculate amount of days in the evaluating month
DaysInMonth = days(DateEnd(j)-DateStart(j)) + 1; data = cell([1, length(DaysInMonth)]); 

%--- For loop for debugging mode
if isequal(inputs.Debug_Mode, 1)

    for i = 1:DaysInMonth

        %--- Setting the current processing day
        inputs.Processing_Day = DateStart(j) + days(i - 1); 

        %--- If the day is not is skip-day log... proceed to calculation
        if isempty(intersect(inputs.Processing_Day, SkipDays))

            try
                if SC == 1
                    data{i} = compute_GGOMO(inputs);
                else
                    data{i} = compute_GG2MO(inputs); 
                end

            catch err
                fprintf(2,'%s\n',err.message);
                disp(cat(2, 'Processing Error. Skipping...', datestr(inputs.Processing_Day)));
                data{i} = []; 
            end

        %--- Otherwise... throw error
        else
            disp(cat(2, 'Data is degraded. Skipping...', datestr(inputs.Processing_Day)));
            data{i} = []; 
        end
    end
    [yr, mnt] = ymd(DateStart(j)); % Extracting year/month for current month of solutions
else

%--- Initializing processing array for parloop
Processing_Days = DateStart(j) + days(0:DaysInMonth-1); %Initializing array to reduce overhead for parloop

%--- Parallel mode for performance
    parfor i = 1:DaysInMonth

        %--- If the day is not is skip-day log... proceed to calculation
        if isempty(intersect(Processing_Days(i), SkipDays))
            
            try
                if SC == 1
                    data{i} = compute_GGOMO(inputs, Processing_Days(i));
                else
                    data{i} = compute_GG2MO(inputs, Processing_Days(i));
                end
                
            catch err
                
                fprintf(2,'%s\n',err.message);
                disp(cat(2, 'Processing Error. Skipping...', datestr(Processing_Days(i))));
                data{i} = []; 
            end
            
        %--- Otherwise... throw error
        else
            disp(cat(2, 'Data is degraded. Skipping...', datestr(Processing_Day(i))));
            data{i} = []; 
        end
    end
    [yr, mnt] = ymd(Processing_Days(1)); % Extracting year/month for current month of solutions
    
end

%--- Concatenating cell array into matrix for output
DataOut = []; 
for i = 1:length(data)
   DataOut = cat(1, DataOut, data{1,i});
end
clear data  

%--- Writing out dasta products and structure whose inputs generated data
if ~isempty(DataOut) && ~isequal(inputs.Debug_Mode, 1)
    cd(inputs.Path_Out)

    %--- Writing out .mat file
    if SC == 1
        VarName = sprintf('%sMonthly_Sols\\GRACE_%s_GRAD_%s_%s.mat', inputs.Path_Out, inputs.GRACE_ID, num2str(yr), num2str(mnt));
    else
        VarName = sprintf('%sMonthly_Sols\\GRACE_TWOSAT_GRAD_%s_%s.mat', inputs.Path_Out, num2str(yr), num2str(mnt));
    end

    save(VarName, 'DataOut', '-v7.3'); clear DataOut; 

    %--- Writing out structre
    input_parsed = inputs; 

    %--- Adding selected ACC product to structure
    warning('off','all')
    inputs.ACC_Product = process_inputs(inputs); 
    warning('on','all')
    empty_index = structfun(@isempty, inputs); 
    
    %--- Adding empty field entries with string so it gets written out
    fns = fieldnames(inputs); 
    for i = 1:length(fns)
        if empty_index(i) == 1
        inputs.(fns{i}) = 'User did not set. '; 
        end
    end
    
    %--- Writing modified input structure out with more info
    writestruct(inputs, strcat(VarName(1:end-10), '_Input_Logs', '.xml'))

    %--- Returning to original input structure
    inputs = input_parsed; 
end
end

cd(inputs.Working_Directory);
end


