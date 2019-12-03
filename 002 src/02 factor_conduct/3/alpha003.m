function [X, offsetSize] = alpha003(stock)
% main function
% SUM((CLOSE = DELAY(CLOSE, 1) ? 0: CLOSE - (CLOSE > DELAY(CLOSE, 1) ?
% MIN(LOW, DELAY(CLOSE, 1)): MAX(HIGH, DELAY(CLOSE, 1)))), 6)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.high, stock.low, stock.close);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, low, close)
% function compute alpha
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
    offsetSize = 6;
end
    
