function [X, offsetSize] = alpha063(stock)
% main function
% SMA(MAX(CLOSE - DELAY(CLOSE, 1), 0), 6, 1) / SMA(ABS(CLOSE - DELAY(CLOSE,
% 1)), 6, 1) * 100
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.close);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(close)
% function compute alpha
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    maxMatrix = max(close - delay, zeros(m, n));
    absMatrix = abs(close - delay);
    
    exposure = sma(maxMatrix, 6, 1)./ sma(absMatrix, 6, 1) * 100;
    offsetSize = 6;
end
