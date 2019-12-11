classdef CleanDataModule < handle
    %CLEANDATAMODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = public, GetAccess = public)
        rawStruct;
    end
    
    properties(SetAccess = protected, GetAccess = public)
        selectedStruct;
        preSelectedStruct;
    end
    
    properties(Access = private)
        updateRows;
    end
    
    properties(Constant)
        defaultUpdateCriteria = 'tradeableStocksSelectionCriteria.json';
        defaultHistoryCriteria = 'tradeableStocksAlongHistory.json';
        defaultTableNamesToSelect = 'tableNamesToSelect.json';
        defaultFillDataMethod = 'defaultFillDataMethods.json';
    end
    
    methods
        % get methods here
        function rawStruct = get.rawStruct(obj)
            rawStruct = obj.rawStruct;
        end
        
        % set methods here
        function set.rawStruct(obj,inputStruct)
            obj.rawStruct = inputStruct;
        end
        
        function set.preSelectedStruct(obj,inputStruct)
            obj.preSelectedStruct = inputStruct;
        end
        
        function set.updateRows(obj,inputNumber)
            obj.updateRows = inputNumber;
        end
    end
    
    methods(Access = public)
        % constructor here
        function obj = CleanDataModule()
            disp("One-click start, use obj.runHistory()");
        end
        
        % run update one-time
        oneTimeStructToUpdate = runUpdate(obj);
        
        % run update for history
        historyToUpdate = runHistory(obj);
        
        % save results
        function saveUpdate = saveUpdate(obj,structName)
            saveUpdate = [];
        end
        
        % save history result
        function saveHistory = saveHistory(obj,structName)
            saveHistory = [];
        end
    end
    
    methods(Access = protected)
        %utils
        criteriaStruct = jsonDecoder(obj,fname);
        
        %callable methods
        tradeableStocksRow = getTradeableStocksUpdate(obj);
        
        tradeableStocksHistory = getTradeableStocksHistory(obj);
        
        structRows = getStructToCleanUpdate(obj);
        
        structMatrix = getStructToCleanHistory(obj);
        
        checkSummaryOfTableNames = checkStructAfterSelection(obj);
        
        % below are utils
        dynamicPointer = parseStringToStructPath(S, fieldlist);
        
    end
end

