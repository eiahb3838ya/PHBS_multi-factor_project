function alpha = Alpha83(stock)
    [m, n] = size(stock.properties.high);
    rankHigh = sort(stock.properties.high);
    rankVolume = sort(stock.properties.volume);
    
    coviance = zeros(m, n);
    for j = 1:n
        for i = 1: 4
            covMatrix = cov(rankHigh(1: i, j), rankVolume(1: i, j));
            coviance(i, j) = covMatrix(1, 2);
        end
        for i = 5: m
            covMatrix = cov(rankHigh(i - 4: i, j), rankVolume(i - 4: i, j));
            coviance(i, j) = covMatrix(1, 2);
        end
    end
    alpha = -1 * sort(coviance);
end