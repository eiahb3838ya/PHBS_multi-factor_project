function alpha = Alpha43(stock)
    [m, n] = size(stock.properties.close);
    delay = zeros(m, n);
    delay(2:m, :) = stock.properties.close(1:m-1, :);
    matri = stock.properties.close;
    matri(stock.properties.close < delay) = -stock.properties.volume(stock.properties.close < delay);
    matri(stock.properties.close == delay) = 0;
    matri(stock.properties.close > delay) = stock.properties.volume(stock.properties.close > delay);
    
    alpha = zeros(m, n);
    for i = 1:5
        alpha(i, :) = sum(matri(1: i, :), 'omitnan');
    end
    for i = 6:m
        alpha(i, :) = sum(matri(i - 5: i, :), 'omitnan');
    end
end
    