function [X, offsetSize] = alpha093(stock)
% main function
% SUM((OPEN >= DELAY(OPEN, 1) ? 0: MAX((OPEN - LOW), (OPEN - DELAY(OPEN,
% 1)))),20)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.open, stock.properties.low);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(open, low)
% function compute alpha
    [m, n] = size(open);
    delay = [zeros(1, n);open(1: m - 1,:)];
    maxMatrix = max((open - low), (open - delay));
    matrix = zeros(m, n);
    matrix(open >= delay) = 0;
    matrix(open < delay) = maxMatrix(open < delay);
    
    exposure = sumPast(matrix, 20);
    offsetSize = 20;
end
