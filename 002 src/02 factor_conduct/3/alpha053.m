function [X, offsetSize] = alpha053(stock)
% main function
% COUNT(CLOSE > DELAY(CLOSE, 1), 12) / 12 * 100
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
    compare = close > delay;
    exposure = sumPast(compare, 12) ./ 12 .* 100;
    offsetSize = 12;
end
