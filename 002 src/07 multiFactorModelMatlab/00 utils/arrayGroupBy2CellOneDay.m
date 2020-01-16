function [outputCell, elementIndicator] = arrayGroupBy2CellOneDay(arr1, groupBySectorVector, stockScreenOneDay)
%ARRAYGROUPBY2CELL given an array, can be matrix or cube; 
% according to groupby vector, which is a ROW vector indicating arr1's 
% corresponding position's group number(must be positive!).
%   When encounting nans in groupByMat, will use most frequent element, if
%   it is a column with all nans, will be marked as no-catgory.
    
    % init arr1, isCube and nanFlag(if there exists a column of all nans)
    isCube = (length(size(arr1)) == 3);
    nanFlag = 0;
    
    %fill nan
    for col = 1:size(groupBySectorVector,2)
        % in case nans
        if isnan(groupBySectorVector(:,col))
            groupBySectorVector(:,col) = 0;
            nanFlag = 1;
        end
    end
    
    % pre-assign memory for outputCell
    outputCellLength = length(unique(groupBySectorVector)) - nanFlag;
    outputCell = cell(1, outputCellLength);
    
    % classify face: days by stocks
    allElements = unique(groupBySectorVector);
    for groupByNumber = 1:length(allElements) - nanFlag
        % exclude 0
        if isCube
            outputCell{groupByNumber} = arr1(:, ...
                intersect(find(groupBySectorVector == allElements(groupByNumber+nanFlag)), find(stockScreenOneDay==1)),...
                :);
        else
            outputCell{groupByNumber} = arr1(:, ...
                intersect(find(groupBySectorVector == allElements(groupByNumber+nanFlag)), find(stockScreenOneDay==1))...
                );
        end
    end
    elementIndicator = setdiff(allElements,0);
end

