function alpha = Alpha53(stock)
    [m, n] = size(stock.properties.close);
    delay = zeros(m, n);
    delay(2:m, :) = stock.properties.close(1:m-1, :);
    compare = stock.properties.close > delay;
    alpha = zeros(m, n);
    for i = 1:11
        num = sum(compare(1:i, :), 'omitnan');
        alpha(i, :) = num./ i.* 100;
    end
    for i = 12: m
        num = sum(compare(i-12: i, :), 'omitnan');
        alpha(i, :) = num./ 12.* 100;
    end
end
