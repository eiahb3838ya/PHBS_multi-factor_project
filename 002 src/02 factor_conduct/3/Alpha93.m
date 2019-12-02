function alpha = Alpha93(stock)
    [m, n] = size(stock.properties.open);
    delay = zeros(m, n);
    delay(2:m, :) = stock.properties.open(1:m-1, :);
    maxMatrix = max((stock.properties.open - stock.properties.low), (stock.properties.open - delay));
    matrix = zeros(m, n);
    matrix(stock.properties.open >= delay) = 0;
    matrix(stock.properties.open < delay) = maxMatrix(stock.properties.open < delay);
    
    alpha = zeros(m, n);
    for i = 1: 19
        alpha(i, :) = sum(matrix(1: i, :), 'omitnan');
    end
    for i = 20: m
        alpha(i, :) = sum(matrix(i - 19: i, :), 'omitnan');
    end
end