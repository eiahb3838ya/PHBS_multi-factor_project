function filledTable = fillDataPlugIns(obj, workingTable)
%FILLDATAPLUGINS a util, fill nan data
% fillMethod, cell of size 1x2, first element: method fillna in the
% beginning of table; second element: method fillna in the end of table,
% e.g. fillMethod can be {["constant",0],["movmean",3]}. Following shows all
% methods of fillna for a table(matrix). 
%       |major params   |other params
%       |'constant'     | value to be filled in
%       |'previous'     | N/A
%       |'next'         | N/A(caution:future data!)
%       |'linear'       | N/A(caution:future data!)
%       |'nearest'      | N/A(caution:future data!)
%       |'mostFrequent' | N/A
%       |'movmean'      | window size
%       |'movmedian'    | window size
%       |'spline'       | N/A(caution:future data!)
%       |'pchip'        | N/A(caution:future data!)

    
    % init fillMethod struct
    fillMethodStruct = obj.jsonDecoder(obj.defaultFillDataMethod);
    fillMethod = cell(1,2);
    
    fillMethod{1} = fillMethodStruct.fillHead;
    fillMethod{2} = fillMethodStruct.fillCommon;
        
    % init method 
    endValueMethod = fillMethod{1}{1}; %
    commonMethod = fillMethod{2}{1};
    
    % check fillMethod params
    if ~(strcmp(endValueMethod, 'constant') || strcmp(endValueMethod, 'next') ||...
            strcmp(endValueMethod, 'nearest') || strcmp(endValueMethod, 'mostFrequent'))
        error 'fill head can only choose constant, next, nearest, most frequent.';
    elseif ((strcmp(commonMethod, 'constant') || strcmp(commonMethod, 'movmean') ||...
            strcmp(commonMethod, 'movmedian')) && size(fillMethod{2},2) == 1) ||...
            (strcmp(endValueMethod, 'constant') && size(fillMethod{1},2) == 1 )
        error 'please specify second parameter of each cell in the fillMethod.';
    end
    
    % filling start
    feedTableAfterDeletion = workingTable;
    filledTable = zeros(size(feedTableAfterDeletion));
    if ~(strcmp(commonMethod, 'mostFrequent') ||...
            strcmp(endValueMethod, 'mostFrequent'))
        if size(fillMethod{1},2) == 1 && size(fillMethod{2},2) == 1
            commonMethod = convertStringsToChars(commonMethod);
            endValueMethod = convertStringsToChars(endValueMethod);
            for col = 1:size(filledTable,2)
                filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                    commonMethod, 'EndValues', endValueMethod);
            end
        elseif size(fillMethod{1},2) == 1 && size(fillMethod{2},2) == 2
            commonMethod = convertStringsToChars(commonMethod);
            endValueMethod = convertStringsToChars(endValueMethod);
            for col = 1:size(filledTable,2)
                filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                    commonMethod, str2num(fillMethod{2}{2}), 'EndValues', endValueMethod);
            end
        elseif size(fillMethod{1},2) == 2 && size(fillMethod{2},2) == 1
            commonMethod = convertStringsToChars(commonMethod);
            for col = 1:size(filledTable,2)
                filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                    commonMethod, 'EndValues', str2num(fillMethod{1}{2}));
            end
        elseif size(fillMethod{1},2) == 2 && size(fillMethod{2},2) == 2
            commonMethod = convertStringsToChars(commonMethod);
            for col = 1:size(filledTable,2)
                filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                    commonMethod, str2num(fillMethod{2}{2}), 'EndValues', str2num(fillMethod{1}{2}));
            end
        else
            error 'other errors,use canonical fillMethod please!';
        end
    elseif strcmp(commonMethod, 'mostFrequent') && size(fillMethod{1},2) == 1
        endValueMethod = convertStringsToChars(endValueMethod);
        for col = 1:size(filledTable,2)
            filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                'constant', mode(feedTableAfterDeletion(:,col)),...
                'EndValues', endValueMethod);
        end
    elseif strcmp(commonMethod, 'mostFrequent') && size(fillMethod{1},2) == 2
        for col = 1:size(filledTable,2)
            filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                'constant', mode(feedTableAfterDeletion(:,col)),...
                'EndValues', str2num(fillMethod{1}{2}));
        end
    else
        error 'other errors, use canonical fillMethod please!';
    end

    
end

