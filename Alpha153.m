function alpha = Alpha153(stock)
    [m, n] = size(stock.properties.close);
    MA3 = zeros(m, n);
    MA6 = zeros(m, n);
    MA12 = zeros(m, n);
    MA24 = zeros(m, n);
    for i = 1: 2
        MA3(i, :) = mean(sum(stock.properties.close(1: i, :), 'omitnan'));
    end
    for i = 3: m
        MA3(i, :) = mean(sum(stock.properties.close(i - 2: i, :), 'omitnan'));
    end
    for i = 1: 5
        MA6(i, :) = mean(sum(stock.properties.close(1: i, :), 'omitnan'));
    end
    for i = 6: m
        MA6(i, :) = mean(sum(stock.properties.close(i - 5: i, :), 'omitnan'));
    end
    for i = 1: 11
        MA12(i, :) = mean(sum(stock.properties.close(1: i, :), 'omitnan'));
    end
    for i = 12: m
        MA12(i, :) = mean(sum(stock.properties.close(i - 11: i, :), 'omitnan'));
    end
    for i = 1: 23
        MA24(i, :) = mean(sum(stock.properties.close(1: i, :), 'omitnan'));
    end
    for i = 24: m
        MA24(i, :) = mean(sum(stock.properties.close(i - 23: i, :), 'omitnan'));
    end
    alpha = (MA3 + MA6 + MA12 + MA24)./ 4;
end