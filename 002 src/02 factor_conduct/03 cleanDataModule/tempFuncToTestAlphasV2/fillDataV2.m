function filledTables = fillData(feedStruct, fieldNames, fillMethod)
% FILLDATA combines delete nan and fill nan
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


    % check validity of input: fieldName
    for fieldName = fieldNames
        if isfield(feedStruct, fieldName) == 0
            error 'field name not contained in the given structure';
        end
    end
    
    % call nan deletion first
    feedTables = cell(length(fieldNames));
    reserveRecord = ones(1,size(feedStruct.(fieldNames(1)),2));
    for count = 1:length(fieldNames)
        fieldName = fieldNames(count);
        feedTables{count} = feedStruct.(fieldName);
        reserveRecord = deleteInfoFromTradingV2(feedStruct, fieldName).*reserveRecord;
    end
    
    % feedTable after deletion
    feedTablesAfterDeletion = cell(length(fieldNames));
    for count = 1:length(fieldNames)
        feedTableAfterDeletion = feedTables{count};
        feedTablesAfterDeletion{count} = feedTableAfterDeletion(:,find(reserveRecord==1));
    end
    
    
    % check fillMethod format
    if ~iscell(fillMethod)
        error 'fillMethod params must be cell matrix of size 1x2!';
    elseif sum(size(fillMethod)==[1,2])~=2
        error 'fillMethod params must be cell matrix of size 1x2!';
    elseif isempty(fillMethod{1}) || isempty(fillMethod{2})
        error 'cell matrix content cannot be empty!';
    end
        
    % init method 
    endValueMethod = fillMethod{1}(1);
    commonMethod = fillMethod{2}(1);
    
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
    filledTables = struct();
    for count = 1:length(fieldNames)
        feedTableAfterDeletion = feedTablesAfterDeletion{count};
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
                        commonMethod, str2num(fillMethod{2}(2)), 'EndValues', endValueMethod);
                end
            elseif size(fillMethod{1},2) == 2 && size(fillMethod{2},2) == 1
                commonMethod = convertStringsToChars(commonMethod);
                for col = 1:size(filledTable,2)
                    filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                        commonMethod, 'EndValues', str2num(fillMethod{1}(2)));
                end
            elseif size(fillMethod{1},2) == 2 && size(fillMethod{2},2) == 2
                commonMethod = convertStringsToChars(commonMethod);
                for col = 1:size(filledTable,2)
                    filledTable(:,col) = fillmissing(feedTableAfterDeletion(:,col),...
                        commonMethod, str2num(fillMethod{2}(2)), 'EndValues', str2num(fillMethod{1}(2)));
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
                    'EndValues', str2num(fillMethod{1}(2)));
            end
        else
            error 'other errors, use canonical fillMethod please!';
        end

        if sum(isnan(filledTable),'all') == 0
            disp([fieldNames(count),': FILLING summary: no nan, finished!']);
        else
            totalNans = sum(isnan(filledTable),'all');
            totalCols = find(sum(isnan(filledTable),1)~=0);
            %to comment the following line
            disp(totalCols(1))

            disp([fieldNames(count),': FILLING summary: nan exists!There are ',num2str(totalNans),' nans in all, '...
                ,num2str(size(totalCols,2)) ,' colums have nan.please use other pair of method or check mannually!']);
        end
        
        filledTables.(fieldNames(count)) = filledTable;
        
    end
end