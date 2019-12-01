function alpha = Alpha183(stock)
    [m, n] = size(stock.properties.close);
    mean24 = zeros(m, n);
    std24 = zeros(m, n);
    for i = 1: 23
        mean24(i, :) = mean(sum(stock.properties.close(1: i, :), 'omitnan'));
        std24(i, :) = std(stock.properties.close(1: i, :), 'omitnan');
    end
    for i = 24: m
        mean24(i, :) = mean(sum(stock.properties.close(i - 23: i, :), 'omitnan'));
        std24(i, :) = std(stock.properties.close(i - 23: i, :), 'omitnan');
    end
    cumSum = cumsum(stock.properties.close - mean24);
    cumSum = cumSum(m, :);
    maxCum = max(cumSum);
    minCum = min(cumSum);
    alpha = (maxCum - minCum)./ std24;
end
    
    