function alpha = Alpha3(stock)
    [m, n] = size(stock.properties.close);
    delay = zeros(m, n);
    delay(2:m, :) = stock.properties.close(1:m-1, :);
    matri1 = stock.properties.close;
    matri1(stock.properties.close == delay) = 0;
    matri2 = stock.properties.close;
    minMat = min(stock.properties.low, delay);
    maxMat = max(stock.properties.high, delay);
    matri2(stock.properties.close > delay) = minMat(stock.properties.close > delay);
    matri2(stock.properties.close <= delay)  = maxMat(stock.properties.close <= delay);
    matri = matri1 - matri2;
    
    alpha = zeros(m, n);
    for i = 1:5
        alpha(i,:) = sum(matri(1:i, :), 'omitnan');
    end
    for i = 6:m
        alpha(i, :) = sum(matri(i-5:i, :), 'omitnan');
    end
end
    