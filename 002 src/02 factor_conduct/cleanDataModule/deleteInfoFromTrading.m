function reserveColumns = deleteInfoFromTrading(feedStruct, fieldName)
% feedStruct is a structure contains OHLC,volume,amount,tradeDay, stDay etc. information
% from exchange.
% fieldName is a string indicates which table in the feedStruct should be
% referred.
% reserveRecord is a summary of columns(i.e. which company) to be reserved
% NOTE: if fieldName is not tradeDay and stTable(means not 0-1 table), then
% the criteria to delete data is count of 'nan' value.

    % check validity of input: filedName
    if isfield(feedStruct, fieldName) == 0
        error 'field name not contained in the given structure';
    end
    
    % set target table name and corresponding threshold
    % all inequalities: >=, <
    tradeDay = 'tradeDayTable';
    n1 = 360;
    
    stTable = 'stTable';
    n2 = 180;
    
    otherKeyword = fieldName;
    n3 = 180;
    
    
    % reserved columns from trade day
    if strcmp(fieldName,tradeDay)
        %get non-trade days
        nontradeDay = 1 - feedStruct.(tradeDay);
        deleteRecord = find(sum(nontradeDay,1)>=n1);
        reserveColumns = setdiff(1:size(nontradeDay,2), deleteRecord);
        return;
    end
    
    % reserved column from st table
    if strcmp(fieldName,stTable)
        maxStDayByStockCol = zeros(1, size(feedStruct.(stTable),2));
        stTable = feedStruct.(stTable);
        for col = 1:size(stTable,2)
            expandColumn = [1; diff(stTable(:,col))~=0; 1]; %1 if value changes
            repetitionTimeConsecutiveNumber = diff(find(expandColumn));
            repetitionTimeBackToArray = repelem(repetitionTimeConsecutiveNumber, repetitionTimeConsecutiveNumber);
            maxConsecutiveStDay = max(repetitionTimeBackToArray(stTable(:,col)==1));
            if isempty(maxConsecutiveStDay) 
                maxStDayByStockCol(1,col) = 0;
            else
                maxStDayByStockCol(1,col) = maxConsecutiveStDay;
            end
        end
        reserveColumns = maxStDayByStockCol(maxStDayByStockCol<n2);
    end
    
    % other keyword
    if isempty(feedStruct.(fieldName))
        error 'desired fieldName in the struct is empty!';
    else
        keywordTable = feedStruct.(otherKeyword);
        nanStatKeywordTable = sum(isnan(keywordTable),1);
        reserveColumns = nanStatKeywordTable(nanStatKeywordTable < n3);
        
        if sum(keywordTable(:,reserveColumns),'all') == 0
            disp(['DELETION summary: no nan exists in ', otherKeyword,' table']);
        else
            disp(['DELETION summary: nan still exist in', otherKeyword,' table']);
        end
    end

end



