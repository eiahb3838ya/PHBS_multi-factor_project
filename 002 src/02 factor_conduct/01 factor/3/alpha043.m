function [X, offsetSize] = alpha043(stock)
% main function
% SUM((CLOSE > DELAY(CLOSE, 1) ? VOLUME: (CLOSE < DELAY(CLOSE, 1) ?
% -VOLUME: 0)), 6)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.close, stock.properties.volume);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(close, volume)
% function compute alpha
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    matrix = close;
    matrix(close < delay) = -volume(close < delay);
    matrix(close == delay) = 0;
    matrix(close > delay) = volume(close > delay);
    
    exposure = sumPast(matrix, 6);
    offsetSize = 6;
end
    
