% SUM((OPEN >= DELAY(OPEN, 1) ? 0: MAX((OPEN - LOW), (OPEN - DELAY(OPEN,
% 1)))),20)

function X = alpha93(stock)
    X = getAlpha93(stock.open, stock.low);
end

function exposure = getAlpha93(open, low)
    [m, n] = size(open);
    delay = [zeros(1, n);open(1: m - 1,:)];
    maxMatrix = max((open - low), (open - delay));
    matrix = zeros(m, n);
    matrix(open >= delay) = 0;
    matrix(open < delay) = maxMatrix(open < delay);
    
    exposure = sumPast(matrix, 20);
end