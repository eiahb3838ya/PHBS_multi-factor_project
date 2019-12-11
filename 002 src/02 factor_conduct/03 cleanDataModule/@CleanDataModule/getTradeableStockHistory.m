function [] = getTradeableStockHistory(obj)
%GETTRADEABLESTOCKHISTORY update all tradeable stocks with
%minimum data required.
%
%   To disable a rule, please set rollingSize parameter to 0
%   To distiguish 0 and 1's real-world meaning, use settingValidIndicator,
%   if indicator is 1, means data == 1 should be reserved, otherwise, means
%   data == 0 should be reserved.
    
    % load parameters
    updateCriteria = obj.jsonDecoder(obj, obj.defaultUpdateCriteria);
    historyCriteria = obj.jsonDecoder(obj, obj.defaultHistoryCriteria);
    
    % get config parameters
    % following values are all array
    maxConsecutiveInvalidLength = updateCriteria.settingClean01.maxConsecutiveInvalidLength;
    maxConsecutiveRollingSize = updateCriteria.settingClean01.maxConsecutiveRollingSize;
    maxCumulativeInvalidLength = updateCriteria.settingClean01.maxCumulativeInvalidLength;
    maxCumulativeRollingSize = updateCriteria.settingClean01.maxCumulativeRollingSize;
    noToleranceRollingSize = updateCriteria.settingClean01.noToleranceRollingSize;
    flag = updateCriteria.settingClean01.flag;
    stride = historyCriteria.settingBacktestStride;
    % and refValidIndicator
    
    % save stride
    obj.set.stride(obj,stride);
    
    % get max slice size
    obj.set.updateRows(obj,max([maxConsecutiveRollingSize, maxCumulativeRollingSize, noToleranceRollingSize]));
    rawDataStruct = obj.getStructToCleanHistory(obj);
    
    % step 0: check updateCriteria validity
    if length(updateCriteria.settingRefer01Table) ~= length(updateCriteria.settingValidIndicator)
        error 'param structure error! settingRefer01 must match settingValidIndicator!';
    end
    
    if ~isfield(updateCriteria, "settingRefer01Table")
        error 'Not define 0-1 table for reference!';
    else
        tableAddr = cell(1,length(updateCriteria.settingRefer01Table));
        refTables = cell(1,length(updateCriteria.settingRefer01Table));
        refValidIndicator = cell(1,length(updateCriteria.settingValidIndicator));
        for count = 1:length(updateCriteria.settingRefer01Table)
            tableAddr{count} = string(updateCriteria.settingRefer01Table{count});
            pathName = strsplit(tableAddr{count},'.');
            refTables{count} = rawDataStruct.(pathName{end});
            refValidIndicator{count} = updateCriteria.settingValidIndicator(count);
        end
        
        % check if read ref table successfully and whether ref table is
        % useable
        for count = 1:length(updateCriteria.settingRefer01Table)
            if isempty(refTables{count})
                error('fail to read "%s" table, because it is empty!', tableAddr{count});
            end
            if sum(sum(isnan(refTables{count})))~=0 %can use sum(A,'all') in R2019b
                error('fail to read "%s" table, because it has nan!', tableAddr{count});
            end
            if ~(isequal(unique(refTables{count}),[0,1]) ||...
                    isequal(unique(refTables{count}),[0;1]))
                error 'elements other than 0,1 exist!';
            end
            if size(refTables{count},1) < obj.get.updateRows(obj)
                error('given 0-1 table has fewer rows than obj.updateRows');
            end
        end
    end
    
    % step2: according to 
    %                                    |-- maxConsecutiveInvalidLength
    %                                    |-- maxConsecutiveRollingSize
    %                                    |-- maxCumulativeInvalidLength     
    %                                    |-- maxCumulativeRollingSize
    %                                    |-- noToleranceRollingSize
    %                                    |-- flag
    % use for loop to clean the data(simulate the situation where you are on the last day of a rolling window)
    % if table size(#rows) is smaller than maximum of rolling size, throw
    % error
    % 1 is invalid, 0 is valid
    
    %check validity of params
    if stride <= 0
        error 'stride must by positive integer!';
    end
    
    if ~(length(maxConsecutiveInvalidLength) == length(maxConsecutiveRollingSize) ||...
            length(maxConsecutiveRollingSize) == length(maxCumulativeInvalidLength) ||...
            length(maxCumulativeInvalidLength) == length(maxCumulativeRollingSize) ||...
            length(maxCumulativeRollingSize) == length(noToleranceRollingSize))
        error 'data selection criteria size not match, size must match!';
    end
    
    if (maxConsecutiveInvalidLength > maxConsecutiveRollingSize) ||...
            (maxCumulativeInvalidLength > maxCumulativeRollingSize)
        error 'rolling size must be >= invalid length.';
    end
    
    if ~(((maxConsecutiveRollingSize <= maxCumulativeRollingSize) ||...
            (maxConsecutiveRollingSize >= noToleranceRollingSize)) || ...
            maxConsecutiveRollingSize == 0 || maxCumulativeRollingSize == 0 ||...
            noToleranceRollingSize == 0)
        error 'if no 0s, should be:cumulative rolling size >=consecutive rolling size >= no tolerance rolling size; otherwise params are senesless.';
    end
    
    % init controller and result
    caseController = [maxCumulativeRollingSize, maxConsecutiveRollingSize, noToleranceRollingSize] ~= 0;
    tradeableStocksMatrix = ones(size(refTables{1}));
    
    %start clean 0-1 table
    % first, for all table, use 1 to represent invalid, 0 represent valid
    for count = 1:length(refValidIndicator)
        if refValidIndicator{count} == 1
            refTables{count} = 1 - refTables{count};
        end
    end
    
    % start case choice
    %caseController = [maxCumulativeRollingSize, maxConsecutiveRollingSize, noToleranceRollingSize] ~= 0;
    choiceIndex = caseController.*[1,2,3];
    try 
        for count = 1:length(refTables)
            currentTable = refTables{count};
            cumulativeRuleResult = dealCumulativeRule(currentTable, maxCumulativeInvalidLength(count), maxCumulativeRollingSize(count),stride);
            consecutiveRuleResult = dealConsecutiveRule(currentTable, maxConsecutiveInvalidLength(count), maxConsecutiveRollingSize(count),stride);
            noToleranceRuleResult = dealNoToleranceRule(currentTable, noToleranceRollingSize(count),stride);
            cellRuleResults = {cumulativeRuleResult, consecutiveRuleResult, noToleranceRuleResult};
            for mat = cellRuleResults(choiceIndex)
                tradeableStocksMatrix = tradeableStocksMatrix.*mat{:};
            end
        end
    catch
        error 'ref tables size not match!';
    end
    
    % step 3: according to flag, choose output format
    if flag == 1
        offsetSize = max([maxCumulativeRollingSize, maxConsecutiveRollingSize, noToleranceRollingSize])-1;%because it is size, not starting index
        columnLength = size(tradeableStocksMatrix,1);
        tradeableStocksMatrix = prod(tradeableStocksMatrix(offsetSize+1:end,:),1);
        tradeableStocksMatrix = repmat(tradeableStocksMatrix, columnLength, 1);
        tradeableStocksMatrix(1:offsetSize,:) = 0;
        obj.set.selectionRecord = tradeableStocksMatrix;
        return;
    end
    
     % otherwise return the matrix
    obj.set.selectionRecord = tradeableStocksMatrix;
    

end

function consecutiveRuleResult = dealConsecutiveRule(table01, maxConsecutiveInvalidLength, maxConsecutiveRollingSize, stride)
%DEALCONSECUTIVERULE to deal with max consecutive invalid length and its
%rolling size.
%Caution: this is not an independent method, should not be called
%independently! If being called independently, please manully check the
%parameter is correct!
%default example, stDay, where 1 is invalid, 0 is valid

    consecutiveRuleResult = zeros(size(table01));

    % dealing case: rolling size 0
    if maxConsecutiveRollingSize == 0
        consecutiveRuleResult = ones(size(table01));
        return;
    end

    %get slice 
    for rowC = maxConsecutiveRollingSize:stride:size(table01,1)
        slice = table01(rowC - maxConsecutiveRollingSize + 1:rowC,:);
        for col = 1:size(slice,2)
            expandColumn = [1; diff(slice(:,col))~=0; 1]; %1 if value changes
            repetitionTimeConsecutiveNumber = diff(find(expandColumn));
            repetitionTimeBackToArray = repelem(repetitionTimeConsecutiveNumber, repetitionTimeConsecutiveNumber);
            maxConsecutiveDay = max(repetitionTimeBackToArray(slice(:,col)==1));
            if isempty(maxConsecutiveDay) 
                consecutiveRuleResult(rowC-stride:rowC,col) = 0;
            else
                consecutiveRuleResult(rowC-stride:rowC,col) = maxConsecutiveDay;
            end
        end
    end
    consecutiveRuleResult = consecutiveRuleResult <= maxConsecutiveInvalidLength;
    consecutiveRuleResult(1:maxConsecutiveRollingSize-1,:) = 0;

end

function cumulativeRuleResult = dealCumulativeRule(table01, maxCumulativeInvalidLength, maxCumulativeRollingSize,stride)
%DEALCUMULATIVERULE to deal with max cumulative invalid length and its
%rolling size.
%Caution: this is not an independent method, should not be called
%independently! If being called independently, please manully check the
%parameter is correct!
%default example, stDay, where 1 is invalid, 0 is valid

    cumulativeRuleResult = zeros(size(table01));

    % dealing case with rolling size 0
    if maxCumulativeRollingSize == 0
        cumulativeRuleResult = ones(size(table01));
        return;
    end

    %get slice
    for rowC = maxCumulativeRollingSize:stride:size(table01,1)
        slice = table01(rowC - maxCumulativeRollingSize + 1:rowC,:);
        judgeSlice = sum(slice,1);
        cumulativeRuleResult(rowC-stride:rowC,:) = judgeSlice;
    end

    cumulativeRuleResult = cumulativeRuleResult <= maxCumulativeInvalidLength;
    cumulativeRuleResult(1:maxCumulativeRollingSize-1,:) = 0;

end

function noToleranceRuleResult = dealNoToleranceRule(table01, noToleranceRollingSize,stride)
%DEALNOTOLERANCERULE to deal with no tolerance rule
%Caution: this is not an independent method, should not be called
%independently! If being called independently, please manully check the
%parameter is correct!
%default example, stDay, where 1 is invalid, 0 is valid

    noToleranceRuleResult = zeros(size(table01));

    % dealing case with rolling size 0
    if noToleranceRollingSize == 0
        noToleranceRuleResult = ones(size(table01));
        return;
    end

    %get slice
    for rowC = noToleranceRollingSize:stride:size(table01,1)
        slice = table01(rowC - noToleranceRollingSize + 1:rowC,:);
        judgeSlice = sum(slice,1);
        noToleranceRuleResult(rowC-stride:rowC,:) = judgeSlice;
    end

    noToleranceRuleResult = noToleranceRuleResult == 0;
    noToleranceRuleResult(1:noToleranceRollingSize-1,:) = 0;

    

end

