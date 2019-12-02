% SUM((CLOSE = DELAY(CLOSE, 1) ? 0: CLOSE - (CLOSE > DELAY(CLOSE, 1) ?
% MIN(LOW, DELAY(CLOSE, 1)): MAX(HIGH, DELAY(CLOSE, 1)))), 6)

function X = alpha3(stock)
    X = getAlpha3(stock.high, stock.low, stock.close);
end

function exposure = getAlpha3(high, low, close)
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    
    matrix1 = close;
    matrix1(close == delay) = 0;
    matrix2 = close;
    minMatrix = min(low, delay);
    maxMatrix = max(high, delay);
    matrix2(close > delay) = minMatrix(close > delay);
    matrix2(close <= delay) = maxMatrix(close <= delay);
    matrix = matrix1 - matrix2;
    
    exposure = sumPast(matrix, 6);
end
    