function [X, offsetSize] = alpha013(stock)
% main function
% (HIGH * LOW)^0.5 - VWAP
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.high, stock.properties.low, stock.properties.vwap);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, low, vwap)
% function compute alpha
    exposure = (high .* low)^0.5 - vwap;
    offsetSize = 1;
end
