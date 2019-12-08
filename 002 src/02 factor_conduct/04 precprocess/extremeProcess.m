function processedTable = extremeProcess(feedStruct, fieldName, paraStruct)
% EXTREMEPROCESS adjusts extreme values into common values
% xAdj = xMedian + n * DMad if x > xMedian + n * DMad
% xAdj = xMedian - n * DMad if x < xMedian - n * DMad
% xAdj = xAdj else
% the median and mean of x is cross-sectional, which means row-wise
% paraStruct, a struct of 2 parameters
% paraStruct.n sets the n parameter in the formula
% paraStruct.choice sets the DMad type of the formula, it has 2 choices
%       |'mean'  | DMad will be the mean of the sequence |x - xMadian|
%       |'median'| DMad will be the median of the sequence |x - xMadian|
    try
        n = paraStruct.n;
        choice = paraStruct.choice;
    catch
        error 'Parameter error';
    end
    
    % check validity of input: fieldName
    if isfield(feedStruct, fieldName) == 0
        error 'field name not contained in the given structure';
    end
    processedTable = feedStruct.(fieldName);
    
    xMedian = median(processedTable, 2);
    if choice == 'mean'
        DMad = mean(processedTable - xMedian, 2);
    elseif choice == 'median'
        DMad = median(processedTable - xMedian, 2);
    else
        error 'Wrong choice';
    end
    
    % count the number of values to be processed
    sumProcessed = sum(sum(processedTable > xMedian + n * DMad));
    sumProcessed = sumProcessed + sum(sum(processedTable < xMedian - n * DMad));
    
    % process the extreme values
    [m, n] = size(processedTable);
    xMax = (xMedian + n * DMad) * ones(1, n);
    xMin = (xMedian - n * DMad) * ones(1, n);
    processedTable(processedTable > xMax) = xMax(processedTable > xMax);
    processedTable(processedTable < xMin) = xMin(processedTable < xMin);
    
    % calculate the percentage of processed values
    percent = sumProcessed * 100 / (m * n);
    disp(["There are ",num2str(sumProcessed),"extrme values processed."])
    disp([num2str(percent),"% of the values are extreme values processed."])
end