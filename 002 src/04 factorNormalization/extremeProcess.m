function processedFactor = extremeProcess(factorMatrix, paraStruct)
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
%     try
%         n = paraStruct.n;
%         choice = paraStruct.choice;
%     catch
%         error 'Parameter error';
%     end
    
    try
        n = paraStruct.n;
    catch
        n = 3;
        disp('Using default n = 3.')
    end
    
    try
        choice = paraStruct.choice;
    catch
        choice = 'mean';
        disp('Using default choice mean.')
    end
    
    processedFactor = factorMatrix;
    xMedian = median(processedFactor, 2, 'omitnan');
    lag = abs(processedFactor - xMedian);
    if strcmp(choice, 'mean')
        DMad = mean(lag, 2, 'omitnan');
    elseif strcmp(choice, 'median')
        DMad = median(lag, 2, 'omitnan');
    else
        error 'Wrong choice';
    end
    
    % count the number of values to be processed
    sumProcessed = sum(sum(processedFactor > xMedian + n * DMad, 'omitnan'));
    sumProcessed = sumProcessed + sum(sum(processedFactor < xMedian - n * DMad, 'omitnan'));
    
    % process the extreme values
    [row, col] = size(processedFactor);
    xMax = (xMedian + n * DMad) * ones(1, col);
    xMin = (xMedian - n * DMad) * ones(1, col);
    processedFactor(processedFactor > xMax) = xMax(processedFactor > xMax);
    processedFactor(processedFactor < xMin) = xMin(processedFactor < xMin);
    
    % calculate the percentage of processed values
    percent = sumProcessed * 100 / (row * col);
    disp(['There are ',num2str(sumProcessed),' extreme values processed.'])
    disp([num2str(percent),'% of the values are extreme values processed.'])
end