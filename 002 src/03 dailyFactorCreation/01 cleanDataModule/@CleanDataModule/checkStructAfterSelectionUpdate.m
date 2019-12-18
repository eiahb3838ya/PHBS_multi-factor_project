function checkSummary = checkStructAfterSelectionUpdate(obj)
%CHECKSTRUCTAFTERSELECTION use selection record to check preSelectedStruct
%   print nan report and call fillData method according to configuration
%NOTE: in this method, the method will look back to the maximum
%length given by obj.updateRows only one time.

    %step 1: get preSelectedStruct and selectionRecord, get minUpdateRows
    updateCriteria = obj.jsonDecoder(obj.defaultUpdateCriteria);
    structToCheck = obj.preSelectedStruct;
    dataIndexToUse = obj.selectionRecord;
    minUpdateRows = obj.minUpdateRows;
    updateRows = obj.updateRows;
    excludeTableNameCell = updateCriteria.settingRefer01Table;
    excludeTableName = strings(1,length(excludeTableNameCell));
    
    for nameCount = 1:length(excludeTableNameCell)
       name = strsplit(excludeTableNameCell{nameCount},'.');
       excludeTableName(nameCount) = name{end};
    end
    %step 2: for all data fields except those declared in settingClean01.settingRefer01Table
    %backtest on each row from updateRows, backtest length is
    %minUpdateRows, thus, the backtest interval is updateRows -
    %minUpdateRows + 1: updateRows and rolling each time. Meanwhile, to get
    %valid data and check anomalities(nans) here, the following steps are
    %designed:
    % for each rolling interval,(if 'update', then no need for this, because check data only run one time)
    % But, if for history, the situation is different,
    % From updateRows - minUpdateRows + 1:end, for all small rolling
    % window, get a matrix of size updateRows - minUpdateRows + 1*#cols,
    % give the value to a zeros(nan means don't use) matrix, sum over
    % all small windows(keep their location still), make all zeros in the
    % given zeros matrix to nan and check no-nan of all non-zero position(exclude those in the beginning)
    fNs = fieldnames(structToCheck);
    rollingSelectionCriteria = repmat(dataIndexToUse(end,:),minUpdateRows,1);
    for count = 1:length(fNs)
        % if table is a table for stock screening, skip it
        if contains(fNs{count}, excludeTableName)
            continue;
        end
        
        % get current working table
        currentWorkingTable = structToCheck.(fNs{count});
        dataRowStartIndx = size(currentWorkingTable,1) - minUpdateRows + 1;
        rollingSelectionArea = currentWorkingTable(dataRowStartIndx:end,:);
        
        if sum(sum(isnan(rollingSelectionArea(find(rollingSelectionCriteria==1)))))~=0
            %if unexpected nan found, call fill data method by default
            nanTotalNumber = sum(sum(isnan(rollingSelectionArea(find(rollingSelectionCriteria==1)))));
            warning("before filling, unexpected nans still exist, %s nans in total, clean of data: %s continues!",num2str(nanTotalNumber), fNs{count});
            
            rollingSelectionArea = obj.fillDataPlugIns(rollingSelectionArea);
            
            % check again
            if sum(sum(isnan(rollingSelectionArea(find(rollingSelectionCriteria==1)))))~=0
                %also can throw error here
                nanTotalNumber = sum(sum(isnan(rollingSelectionArea(find(rollingSelectionCriteria==1)))));
                warning("after filling data, unexpected nans still exist, %s nans in total, clean of data: %s continues! Consider other fillMethod",num2str(nanTotalNumber), fNs{count});
            end
        end
        
        rollingSelectionArea(find(rollingSelectionCriteria==0)) = nan; %nan means don't use
        currentWorkingTable(dataRowStartIndx:end,:) = rollingSelectionArea;
        currentWorkingTable(1:dataRowStartIndx - 1,:) = nan; %nan means don't use
        obj.selectedStruct.(fNs{count}) = currentWorkingTable;
    end
    
    checkSummary = obj.selectedStruct;

end

