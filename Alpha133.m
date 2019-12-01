function alpha = Alpha133(stock)
    [m, n] = size(stock.properties.high);
    highday = zeros(m, n);
    for i = 1: 19
        [~, index] = max(stock.properties.high(1: i, :));
        highday(i, :) = i - index;
    end
    for i = 20: m
        [~, index] = max(stock.properties.high(i - 19: i, :));
        highday(i, :) = i - index;
    end
    alpha = (20 - highday)./ 20.* 100 - Alpha103(stock);
end