classdef CleanDataModule < handle
    %CLEANDATAMODULE document @ github
    
    % struct below
    properties(SetAccess = protected, GetAccess = public) %should be protected and public
        rawStruct;
        preSelectedStruct;
        selectionRecord;
        selectedStruct;
    end
    
    % numbers below
    properties(SetAccess = protected, GetAccess = public) %should be protected and public
        updateRows; %maximum of minimum data to use
        minUpdateRows; %minimum of minimum data to use
    end
    
    % constant properties
    properties(Constant)
        defaultUpdateCriteria = 'tradeableStocksSelectionCriteria.json';
        defaultTableNamesToSelect = 'tableNamesToSelect.json';
        defaultFillDataMethod = 'fillDataMethod.json';
    end
    
    methods(Static)
        function S = getStructSlice(STR, rowIndxToStartSlice)
            fNs = fieldnames(STR);
            for count = 1:length(fNs)
                currentTable = STR.(fNs{count});
                try
                    S.(fNs{count}) = currentTable(rowIndxToStartSlice:end,:);
                catch
                    disp([fNs{count}, " doesn't have sufficient observations!"]);
                    continue;
                end
            end
        end
    end
    
    methods(Access = public)
        % constructor here
        function obj = CleanDataModule(dataStruct)
            disp("CleanDataModule start: please check cleanDataConfig first, read document for start up.");
            % read config.json and cut it into sub json files stored in
            % default names
            % step 1: get data!
            if nargin == 0
                try
                    disp('hello, struct is loading data, please wait...');
                    %load data
                    projectData = load('projectData.mat');
                    obj.rawStruct = projectData.projectData;
                    %clear temp var
                    clear projectData;
                    %check field names validity
                    obj.fieldNameCheck();
                    disp('okay :), the data is loaded successfully.');
                catch
                    error 'default data projectData is not in matlab path!';
                end
            elseif isstring(dataStruct)
                try
                    disp('hello, struct is loading data, please wait...');
                    
                    %load data
                    projectData = load(dataStruct);
                    obj.rawStruct = projectData.projectData;
                    %clear temp var
                    clear projectData;
                    %rename invalid names
                    obj.fieldNameCheck();
                    disp('okay :), the data is loaded successfully.');
                catch
                    error('cannot load %s, maybe not in path',dataStruct);
                end
            elseif isstruct(dataStruct)
                try
                    disp('hello, struct is loading data, please wait...');
                    obj.rawStruct = dataStruct; 
                    %rename invalid names
                    obj.fieldNameCheck();
                    disp('okay :), the data is loaded successfully.');
                catch
                    error 'read struct error!';
                end
            else
                disp('NOT DETECT EFFECTIVE INPUT OF RAW DATA, INIT WITH EMPTY RAW DATA');
                obj.rawStruct = [];
            end
            
        end
        
        % run update one-time
        runUpdate(obj, warningSwitch, forceNotUsedDataToNan);
        
        % run update for history
        runHistory(obj, warningSwitch, forceNotUsedDataToNan);
        
        % get result
        function outS = getResult(obj)
            % GETRESULT should by called after runUpdate or runHistory
            outS = obj.selectedStruct;
        end
        
        % get specific properties
        function outM = getOHLC(obj, tableName)
            try 
                outM = obj.selectedStruct.(tableName);
            catch
                error 'invalid tableName';
            end
        end
        
        % get selection Rule
        function outRule = getStockScreenMatrix(obj)
            try
                outRule = obj.selectionRecord;
            catch
                error 'no rule exists, please runUpdate/runHistory first!';
            end
        end
        
        % set raw STR
        function [] = setRawSTR(obj, STR)
            if isstruct(STR)
                try
                    warning('this is a dangerous operation! making all results using CleanDataModule before this line is inaccurate!');
                    obj.rawStruct = STR;
                catch
                    error 'invalid STR input!';
                end
            else
                error 'input STR must be a struct!';
            end
        end
        
        % plot number of stocks tradeable
        function [] = plotNumTradeableStock(obj)
            try
                disp("plot tradeable stocks, history");
                plot(sum(obj.selectionRecord(obj.updateRows:end,:),2));
                title("counts of tradeable stocks by trading days");
                ylabel("count");
            catch
                error('no data to plot!');
            end
        end
        
        % save result
        function [] = saveResult(obj, keyword)
            % SAVERESULT is used to save result from getResult();
            %       the data is named by "cleanedData_" + keyword + "_YYYYmmdd.mat"
            try
                if nargin == 1
                    keyword = 'saveTagNotSpecified';
                end
                %generate saving names
                fileName = strcat('cleanedData_', keyword, '_', datestr(now, 'yyyymmdd'));
                
                %loop over fieldnames and save them
                fNs = fieldnames(obj.selectedStruct);
                for count = 1:length(fNs)
                    matObj = matfile(fileName, 'Writable', true);
                    matObj.(fNs{count}) = obj.selectedStruct.(fNs{count});
                end
                
            catch
                error 'error in saving data';
            end
        end
        
        % check nans
        function S = reportNanExistence(obj, verbose)
            % REPORTNANEXISTENCE stockScreenMatrix is of same size with
            % table prior to slicing.
            STR = obj.selectedStruct;
            stockScreenMatrix = obj.selectionRecord;
            startScreenRowIndx = obj.updateRows;
            
            structSlice = obj.getStructSlice(STR, startScreenRowIndx);
            try
                stockScreenMatrixSlice = stockScreenMatrix(startScreenRowIndx:end,:);
            catch
                error("invalid stock screen matrix, not have sufficient observations");
            end
            
            %apply stockScreen slice as a mask on struct slice, check nans
            if verbose
                fNs = fieldnames(structSlice);
                for count = 1:length(fNs)
                    currentTable = structSlice.(fNs{count});
                    nanCurrent = sum(sum(isnan(currentTable(find(stockScreenMatrixSlice == 1)))));
                    S.(fNs{count}) = nanCurrent;
                end
            else
                S = 0;
                fNs = fieldnames(structSlice);
                for count = 1:length(fNs)
                    currentTable = structSlice.(fNs{count});
                    nanCurrent = sum(sum(isnan(currentTable(find(stockScreenMatrixSlice == 1)))));
                    S = S + (nanCurrent~=0);
                end
            end
        end
        
        % add inconsistent table to the result
        function [] = addInconsistentTableToResult(obj, tableToAdd, newTableName)
            if isempty(obj.selectedStruct)
                warning("empty selected struct, init a new struct instead");
            end
            
            try
                obj.selectedStruct.(newTableName) = tableToAdd;
            catch
                error("invalid new table name or invalid table to add.");
            end
        end
        
    end
    
    methods(Access = protected)%proteced 
        %------------------------------------------------------
        %utils
        %------------------------------------------------------
        criteriaStruct = jsonDecoder(obj,fname);
        
        dynamicPointer = parseStringToStructPath(obj, S, fieldlist);
        
        filled = fillDataPlugIns(obj, workingTable);
        
        getStructLastRow(obj);
        
        fieldNameCheck(obj);
        
        %------------------------------------------------------
        %callable methods -------------------------------------
        %------------------------------------------------------
        tradeableStocksRow = getTradeableStockUpdate(obj); %checked, Elapsed time is 0.21s
        
        tradeableStocksMatrix = getTradeableStockHistory(obj); %checked, Elapsed time is 12.303552 seconds.
        
        structRows = getStructToCleanUpdate(obj); %checked,Elapsed time is 0.036576 seconds.
        
        structMatrix = getStructToCleanHistory(obj); %checked,Elapsed time is 0.008368 seconds.
        
        checkSummary = checkStructAfterSelectionUpdate(obj, forceNotUsedDataToNan);
        
        checkSummary = checkStructAfterSelectionHistory(obj, forceNotUsedDataToNan);
        
    end
end

