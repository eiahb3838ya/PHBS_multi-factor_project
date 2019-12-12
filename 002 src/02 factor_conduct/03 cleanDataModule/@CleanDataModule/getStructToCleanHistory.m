function structMatrix = getStructToCleanHistory(obj)
% []= getStructToCleanHistory(obj)
%GETSTRUCTTOCLEANHISTORY  make a new copy of structure that is used to feed 
%to stock selection process.
%   NOTE: depend on defaultTableNamesToSelect = 'tableNamesToSelect.json';

    minimumSliceSize = obj.updateRows;
    
    %add warning
    if isempty(minimumSliceSize)
        warning("the properties updateRows is empty!");
    end
    
    fNs = obj.jsonDecoder(obj.defaultTableNamesToSelect);
    
    % step 1: give values back to structMatrix
    structMatrix = struct();
    fN = fieldnames(fNs);
    for count =1: length(fN)
        fN_array = strsplit(fN{count},'_');
        rawFieldData = obj.parseStringToStructPath(obj.rawStruct,strjoin(strsplit(fN{count},'_'),'.'));
        
        structMatrix.(fN_array{end}) = rawFieldData;

        % speical check of table size
        if (size(rawFieldData,1) -  minimumSliceSize + 1 <=0)             
            error('%s has fewer records than minimum slice size, please use get method to check required minimum size',fN);
        end

    end
    
    % step 2: check all tables in structMatrix, if columns size are equal,
    % set selectedStruct to be structMatrix, otherwise throw error
    fieldTableColSize = [];
    fN = fieldnames(structMatrix);
    for count = 1:length(fN)
       currentTable = structMatrix.(fN{count});
       fieldTableColSize = [fieldTableColSize; size(currentTable,2)];
    end
    
    if all(fieldTableColSize == fieldTableColSize(1))
        obj.preSelectedStruct = structMatrix;
    else
        error 'column size of input data not match, please check!';
    end
end


