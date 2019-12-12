classdef CleanDataModule < handle
    %CLEANDATAMODULE document not finished.
    
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
    end
    
    
    methods(Access = public)
        % constructor here
        function obj = CleanDataModule(dataStruct)
            disp("One-click start, use obj.runHistory()");
            % read config.json and cut it into sub json files stored in
            % default names
            % step 1: get data!
            if nargin == 0
                try
                    disp('hello, struct is loading data, please wait...');
                    projectData = load('projectData.mat');

                    obj.rawStruct = projectData.projectData;

                    clear projectData;
                    disp('okay :), the data is loaded successfully.');
                catch
                    error 'default data projectData is not in matlab path!';
                end
            elseif isstring(dataStruct)
                try
                    disp('hello, struct is loading data, please wait...');
                    projectData = load(dataStruct);
                    
                    obj.rawStruct = projectData.projectData;
                    
                    clear projectData;
                    disp('okay :), the data is loaded successfully.');
                catch
                    error('cannot load %s ',dataStruct);
                end
            else
                error 'invalid struct name or struct not in path';
            end
            
        end
        
        % run update one-time
        runUpdate(obj);
        
        % run update for history
        runHistory(obj);
        
        % get result
        function outS = getResult(obj)
            % GETRESULT should by called after runUpdate or runHistory
            outS = obj.selectedStruct;
        end
    end
    
    methods(Access = protected) 
        %------------------------------------------------------
        %utils
        %------------------------------------------------------
        criteriaStruct = jsonDecoder(obj,fname);
        
        dynamicPointer = parseStringToStructPath(obj, S, fieldlist);
        
        % not finished yet!
%         fillDataUpdate(obj, tableNames);
        
        %------------------------------------------------------
        %callable methods -------------------------------------
        %------------------------------------------------------
        tradeableStocksRow = getTradeableStockUpdate(obj); %checked, Elapsed time is 0.21s
        
        tradeableStocksMatrix = getTradeableStockHistory(obj); %checked, Elapsed time is 12.303552 seconds.
        
        structRows = getStructToCleanUpdate(obj); %checked,Elapsed time is 0.036576 seconds.
        
        structMatrix = getStructToCleanHistory(obj); %checked,Elapsed time is 0.008368 seconds.
        
        checkSummary = checkStructAfterSelectionUpdate(obj);
        
        checkSummary = checkStructAfterSelectionHistory(obj);
    end
end

