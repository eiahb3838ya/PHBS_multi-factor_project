function checkSummary = checkStructAfterSelectionUpdate(obj)
%CHECKSTRUCTAFTERSELECTION use selection record to check preSelectedStruct
%   print nan report and call fillData method according to configuration
%NOTE: in this method, the method will look back to the maximum
%length given by obj.updateRows only one time.

    %step 1: get preSelectedStruct and selectionRecord
    structToCheck = obj.get.preSelectedStruct(obj);
    dataIndexToUse = obj.get.selectionRecord(obj);
    
    %step 2: go over the structToCheck and check in dataIndexToUse
    fNs = fieldnames(structToCheck);
    checkSummary = zeros(1,length(fNs));
    for count = 1:length(fNs)
        currentWorkingTable = structToCheck.(fNs{count});
        currentTableToCheck = currentWorkingTable(end - obj.updateRows + 1:end,:);
        elementsToCheck = currentTableToCheck(find(dataIndexToUse(end - obj.updateRows + 1:end,:)==1));
        if sum(isnan(elementsToCheck))~=0
            checkSummary(count) = 0;
            disp(['Table ', fNs{count}, ' has nans, manual check is required.']);
            continue;
        end
        checkSummary(count) = 1;
    end
    
end

