function [] = getStructLastRow(obj)
%GETSTRUCTLASTROW get last row for field in a struct
    %target selectedStruct
    fNs = fieldnames(obj.selectedStruct);
    for count = 1:length(fNs)
        currentFieldTable = obj.selectedStruct.(fNs{count});
        obj.selectedStruct.(fNs{count}) = currentFieldTable(end,:);
    end
end

