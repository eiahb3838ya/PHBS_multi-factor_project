function [X, offsetSize] = alpha133(stock)
% main function
% ((20 - HIGHDAY(HIGH, 20)) / 20) * 100 - ((20 - LOWDAY(LOW, 20)) / 20) * 100
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.high, stock.low);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, low)
% function compute alpha
    exposure = (20 - highday(high, 20))./ 20.* 100 - (20 - lowday(low, 20))./ 20.* 100;
    offsetSize = 20;
end
