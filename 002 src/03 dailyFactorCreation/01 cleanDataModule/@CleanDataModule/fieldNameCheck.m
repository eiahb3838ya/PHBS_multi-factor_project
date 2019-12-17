function [] = fieldNameCheck(obj)
%FIELDNAMECHECK rename field in rawData, e.g. PE_TTM to PETTM

    try
        targetSTR = obj.rawStruct;
    catch
        error 'unexpected error! no struct is fed to the module! please restart or use setRawSTR';
    end
    
    revisedSTR = recursiveChangeNames(targetSTR);
    obj.rawStruct = revisedSTR;
end


function STR = recursiveChangeNames(STR)
    if isstruct(STR)
        fNs = fieldnames(STR);
        for count = 1:length(fNs) 
            currentSTR = STR.(fNs{count});
            if ~isempty(regexp(fNs{count},'_','ONCE'))
                STR = renameStructField(STR,fNs{count},strjoin(strsplit(fNs{count},'_'),''));
            end
            % reload field names
            fNs = fieldnames(STR);
            if isstruct(currentSTR)
                currentSTR = recursiveChangeNames(currentSTR);
                STR.(fNs{count}) = currentSTR;
            end
        end
    end
end