%Alpha11 SMA(VOL*((CLOSE-LOW)-(HIGH-CLOSE))/(HIGH-LOW),11,2)-SMA(VOL*((CLOSE-LOW)-(HIGH-CLOSE))/(HIGH-L
%OW),4,2)

% close = projectData.stock.properties.close;
% low = projectData.stock.properties.low;
% high = projectData.stock.properties.high;
% volume = projectData.stock.properties.volume;

function [X, offsetSize] = alpha111(stock)
    [X, offsetSize] = getAlpha(stock.properties.high, stock.properties.low, stock.properties.close, stock.properties.volume);
end

function [exposure, offsetSize] = getAlpha(high, low, close, volume)
    A = volume.*((close - low) - (high - close))./(high - low);
    exposure = sma(A, 11, 2) - sma(A, 4, 2);
    offsetSize = 1;
end



