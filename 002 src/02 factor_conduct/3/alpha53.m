% COUNT(CLOSE > DELAY(CLOSE, 1), 12) / 12 * 100

function X = alpha53(stock)
    X = getAlpha53(stock.close);
end

function exposure = getAlpha53(close)
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    compare = close > delay;
    exposure = sumPast(compare, 12) ./ 12 .* 100;
end
