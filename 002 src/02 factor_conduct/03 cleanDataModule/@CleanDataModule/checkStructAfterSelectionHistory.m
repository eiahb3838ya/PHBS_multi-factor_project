function checkSummary = checkStructAfterSelectionHistory(obj)
%CHECKSTRUCTAFTERSELECTIONHISTORY use selection record to check preSelectedStruct
%   print nan report and call fillData method according to configuration
%NOTE: in this method, every time the method will look back to the maximum
%length given by obj.updateRows.

    %step 1: get preSelectedStruct and selectionRecord
    structToCheck = obj.get.preSelectedStruct(obj);
    dataIndexToUse = obj.get.selectionRecord(obj);
    
    %step 2: go over the structToCheck and check in dataIndexToUse
    fNs = fieldnames(structToCheck);
    checkSummary = zeros(1,length(fNs));
    for count = 1:length(fNs)
        currentWorkingTable = structToCheck.(fNs{count});
        for rowC = obj.updateRows:size(currentWorkingTable,1)
            currentWorkingSlice = currentWorkingTable(rowC - obj.updateRows + 1:rowC,:);
            currentWorkingDataIndex = dataIndexToUse(rowC - obj.updateRows + 1:rowC,:);
            elementsToCheck = currentWorkingSlice(find(currentWorkingDataIndex==1));
            if sum(isnan(elementsToCheck))~=0
                checkSummary(count) = 0;
                disp(['Table ', fNs{count}, ' has nans, manual check is required.']);
                continue;
            end
        end
        checkSummary(count) = 1;
    end

end

