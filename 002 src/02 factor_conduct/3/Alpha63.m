function alpha = Alpha63(stock)
    [m, n] = size(stock.properties.close);
    delay = zeros(m, n);
    delay(2:m, :) = stock.properties.close(1:m-1, :);
    maxMatri = max(stock.properties.close - delay, zeros(m, n));
    absMatri = abs(stock.properties.close - delay);
    
    sma1 = zeros(m, n);
    sma2 = zeros(m, n);
    for i = 1:5
        sma1(i, :) = mean(maxMatri(1: i, :), 'omitnan');
        sma2(i, :) = mean(absMatri(1: i, :), 'omitnan');
    end
    for i = 6:m
        sma1(i, :) = mean(maxMatri(i - 5: i, :), 'omitnan');
        sma2(i, :) = mean(absMatri(i - 5: i, :), 'omitnan');
    end
    alpha = sma1./ sma2;
    alpha = alpha.* 100;
end