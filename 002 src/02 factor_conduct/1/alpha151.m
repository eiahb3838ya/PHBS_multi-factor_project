% Alpha151 SMA(CLOSE-DELAY(CLOSE,20),20,1)

% close = projectData.stock.properties.close;

function [X, offsetSize] = alpha151(stock)
    [X, offsetSize] = getAlpha(stock.properties.close);
end

function [exposure, offsetSize] = getAlpha(close)
    closeDelay = [zeros(20, size(close, 2));close(1:end-20,:)];
    exposure = sma(close - closeDelay, 20, 1);
    offsetSize = 21
end

