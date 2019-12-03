% Alpha171 ((-1 * ((LOW - CLOSE) * (OPEN^5))) / ((CLOSE - HIGH) * (CLOSE^5))

% close = projectData.stock.properties.close;
% low = projectData.stock.properties.low;
% high = projectData.stock.properties.high;

function [X, offsetSize] = alpha171(stock)
    [X, offsetSize] = getAlpha(stock.properties.high, stock.properties.low, stock.properties.close);
end

function [exposure, offsetSize] = getAlpha(high, low, close)
    exposure = (-1 * ((low - close) .* (open.^5))) ./ ((close - high) .* (close.^5));
    offsetSize = 0;
end

