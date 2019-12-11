function [] = getStructToCleanUpdate(obj)
%GETSTRUCTTOCLEANUPDATE from obj.updateRows to get slice size and make a
%new copy of structure that is used to feed to stock selection process.
%   NOTE: depend on defaultTableNamesToSelect = 'tableNamesToSelect.json';
    
    minimumSliceSize = obj.updateRows;
    fNs = obj.jsonDecoder(obj, obj.defaultTableNamesToSelect);
    
    % step 1: give values back to structRows
    structRows = struct();
    fN = fieldnames(fNs);
    for count =1: length(fN)
        fN_array = strsplit(fN{count},'_');
        rawFieldData = obj.parseStringToStructPath(obj.rawStruct,strjoin(strsplit(fN{count},'_'),'.'));
        try
            structRows.(fN_array{end}) = rawFieldData(end - minimumSliceSize + 1,:);
        catch
            error('%s has fewer records than minimum slice size, please use get method to check required minimum size',fN);
        end
    end
    
    % step 2: check all tables in structRows, if columns size are equal,
    % set selectedStruct to be structRows, otherwise throw error
    fieldTableColSize = [];
    fN = fieldnames(structRows);
    for count = 1:length(fN)
       currentTable = structRows.(fN{count});
       fieldTableColSize = [fieldTableColSize; size(currentTable,2)];
    end
    
    if all(fieldTableColSize == fieldTableColSize(1))
        obj.set.preSelectedStruct(obj, structRows);
    else
        error 'column size of input data not match, please check!';
    end
end

