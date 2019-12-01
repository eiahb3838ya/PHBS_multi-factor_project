function alpha = Alpha103(stock)
    [m, n] = size(stock.properties.low);
    lowday = zeros(m, n);
    for i = 1: 19
        [~, index] = min(stock.properties.low(1: i, :));
        lowday(i, :) = i - index;
    end
    for i = 20: m
        [~, index] = min(stock.properties.low(i - 19: i, :));
        lowday(i, :) = i - index;
    end
    alpha = (20 - lowday)./ 20.* 100;
end