classdef CleanDataModule < handle
    %CLEANDATAMODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = public, GetAccess = public)
        rawStruct;
    end
    
    properties(SetAccess = protected, GetAccess = public)
        preSelectedStruct;
        selectionRecord;
        selectedStruct;
    end
    
    properties(Access = private)
        updateRows;
        stride;
    end
    
    properties(Constant)
        configFile = 'cleanDataConfig.json';
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
        
        function preSelectedStruct = get.preSelectedStruct(obj)
            preSelectedStruct = obj.preSelectedStruct;
        end
        
        function selectionRecord = get.selectionRecord(obj)
            selectionRecord = obj.selectionRecord;
        end
        
        function minimumDataSize = get.updateRows(obj)
            minimumDataSize = obj.updateRows;
        end
        
        % set methods here
        function set.rawStruct(obj,inputStruct)
            obj.rawStruct = inputStruct;
        end
        
        function set.preSelectedStruct(obj,inputStruct)
            obj.preSelectedStruct = inputStruct;
        end
        
        function set.selectionRecord(obj, selectionMat)
            obj.selectionRecord = selectionMat;
        end
        
        function set.selectedStruct(obj, inputStruct)
            obj.selectedStruct = inputStruct;
        end
        
        function set.updateRows(obj,inputNumber)
            obj.updateRows = inputNumber;
        end
        
        function set.stride(obj, stride)
            obj.stride = stride;
        end
    end
    
    methods(Access = public)
        % constructor here
        function obj = CleanDataModule()
            % read config.json and cut it into 4 sub json files stored in
            % default names
            % to be coded
            disp("One-click start, use obj.runHistory()");
        end
        
        % run update one-time
        runUpdate(obj);
        
        % run update for history
        runHistory(obj);
        
%         % save results
%           temporarily not required
%         function saveUpdate = saveUpdate(obj,structName)
%             saveUpdate = [];
%         end
%         
%         % save history result
%         function saveHistory = saveHistory(obj,structName)
%             saveHistory = [];
%         end
    end
    
    methods(Access = protected)
        %utils
        criteriaStruct = jsonDecoder(obj,fname);
        
        % not finished yet!
        fillDataUpdate(obj, tableNames);
        
        dynamicPointer = parseStringToStructPath(S, fieldlist);
        
        %callable methods
        getTradeableStocksUpdate(obj);
        
        getTradeableStocksHistory(obj);
        
        getStructToCleanUpdate(obj);
        
        getStructToCleanHistory(obj);
        
        checkSummary = checkStructAfterSelectionUpdate(obj);
        
        checkSummary = checkStructAfterSelectionHistory(obj);
    end
end

