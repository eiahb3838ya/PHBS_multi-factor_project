% SMA(MAX(CLOSE - DELAY(CLOSE, 1), 0), 6, 1) / SMA(ABS(CLOSE - DELAY(CLOSE,
% 1)), 6, 1) * 100

function X = alpha63(stock)
    X = getAlpha63(stock.close);
end

function exposure = getAlpha63(close)
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    maxMatrix = max(close - delay, zeros(m, n));
    absMatrix = abs(close - delay);
    
    exposure = sma(maxMatrix, 6, 1)./ sma(absMatrix, 6, 1) * 100;
end