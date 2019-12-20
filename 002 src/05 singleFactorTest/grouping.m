function groupedCube = grouping(factorCube, mktSize, groupRule)
% GROUPING returns the Cube of the rank for stocks under the scoring points
%   of each factor under certain rules.
% factorCube is the raw m x n x l cube with its first dimension as dates, 
%   second dimension as stocks and third dimension as factors.
% mktSize is a m x n matrix with its first dimension as dates and second dimension
%   as stocks, the values in it are the sizes of companies on different
%   dates.
% groupRule is a struct with rules for the grouping.
% groupRule.delOpt = {method, value}, default = {'percent', 0.3} is a cell
%   if method is 'percent', then value should be in [0, 1] as the
%       percentage of the smallest sizes that we drop;
%   if method is 'threshold', then value should be the threshold if the
%       sizes of the stock is smaller than which then we drop;
% groupRule.bracket = {nLayer, method}, default = {5, {'quantile', [0.2, 
% 0.2, 0.2, 0.2, 0.2]}} is a cell
%   nLayer is the number of layers we need to group into;
%   method is a cell to determine the method for grouping
%       if method{1} is 'quantile', method{2} inputs the percent of each
%           group;
%       if method{1} is 'threshold', method{2} inputs the thresholds for
%           each group;
% groupRule.reserveOpt = 0/1, default is 0 is a boolean
%   0 means stocks with NaN value will not be considered in the grouping;
%   1 means stocks with NaN value will be considered in the grouping.

    % default settings
    try
        delOpt = groupRule.delOpt;
    catch
        delOpt = {'percent', 0.3};
        disp('Using default delOpt {percent, 0.3}.');
    end
    
    try
        bracket = groupRule.bracket;
    catch
        bracket = {5, {'quantile', [0.2, 0.2, 0.2, 0.2, 0.2]}};
        disp('Using default bracket {5, {quantile, [0.2, 0.2, 0.2, 0.2, 0.2]}}.');
    end
    
    try
        reserveOpt = groupRule.reserveOpt;
    catch
        reserveOpt = 0;
        disp('Using default reserveOpt 0.');
    end
    
    % errors
    [m, n, l] = size(factorCube);
    [m1, n1] = size(mktSize);
    if m ~= m1 || n ~= n1
        error 'sizes of cube and mktSize do not match'
    end
    
    [~, n2] = size(bracket{2}{2});
    if bracket{1} ~= n2
        error 'number of layers does not match settings.'
    end
    if strcmp(bracket{2}{1}, 'quantile') && (sum(bracket{2}{2}) ~= 1)
        error 'the sum of quantiles is not 1.'
    end
    
    % delete
    delCube = zeros(m, n, l);
    if strcmp(delOpt{1}, 'percent')
        sortMktSize = sort(mktSize, 2);
        criticalMktSize = sortMktSize(:, ceil(n * delOpt{2}));
        for i = 1: l
            matrixToDelete = reshape(factorCube(:, :, i), m, n);
            matrixToDelete(mktSize <= criticalMktSize) = 0;
            delCube(:, :, i) = matrixToDelete;
        end
    elseif strnmp(delOpt{1}, 'threshold')
        for i = 1: l
            matrixToDelete = reshape(factorCube(:, :, i), m, n);
            matrixToDelete(mktSize <= delOpt{2}) = 0;
            delCube(:, :, i) = matrixToDelete;
        end
    else
        error 'no such delete method.'
    end
    
    % reserve
    reserveCube = zeros(m, n, l);
    if reserveOpt == 0
        for i = 1: l
            matrixPostReserve = reshape(delCube(:, :, i), m, n);
            matrixPostReserve(isnan(matrixPostReserve)) = 0;
            reserveCube(:, :, i) = matrixPostReserve;
        end
    end
    
    % group
    groupedCube = zeros(m, n, l);
    if strcmp(bracket{2}{1}, 'quantile')
        percent = cumsum(bracket{2}{2});
        criticalRank = n * percent;
        criticalRank = [0, criticalRank];
        nLayer = bracket{1};
        for i = 1: l
            matrixToSort = reshape(reserveCube(:, :, i), m, n);
            [~, sortedIndex] = sort(matrixToSort, 2);
            sortedIndex(matrixToSort == 0) = 0;
            sortedIndex(isnan(matrixToSort)) = NaN;
            for j = 1: nLayer
                sortedIndex((sortedIndex > criticalRank(j)) & (sortedIndex <= criticalRank(j + 1))) = j;
            end
            groupedCube(:, :, i) = sortedIndex;
        end
    elseif strcmp(bracket{2}{1}, 'threshold')
        criticalValue = [0, bracket{2}{2}];
        nLayer = bracket{1};
        for i = 1: l
            matrixToGroup = reshape(reserveCube(:, :, i), m, n);
            for j = 1: nLayer
                matrixToGroup((matrixToGroup > criticalValue(j)) & (matrixToGroup >= criticalValue(j + 1))) = j;
            end
            groupedCube(:, :, i) = matrixToGroup;
        end
    else
        error 'no such method to group.'
    end
end
        