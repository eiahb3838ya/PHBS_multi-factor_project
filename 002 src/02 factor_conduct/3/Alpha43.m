% SUM((CLOSE > DELAY(CLOSE, 1) ? VOLUME: (CLOSE < DELAY(CLOSE, 1) ?
% -VOLUME: 0)), 6)

function X = alpha43(stock)
    X = getAlpha43(stock.close, stock.volume);
end

function exposure = getAlpha43(close, volume)
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    matrix = close;
    matrix(close < delay) = -volume(close < delay);
    matrix(close == delay) = 0;
    matrix(close > delay) = volume(close > delay);
    
    exposure = sumPast(matrix, 6);
end
    