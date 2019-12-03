% alpha11
% sum(((close - low) - (high - close)) ./(high - low).*volume, 6)
% close = projectData.stock.properties.close;
% low = projectData.stock.properties.low;
% high = projectData.stock.properties.high;
% volume = projectData.stock.properties.volume;


function [X, offsetSize] = alpha11(stock)
    [X, offsetSize] = getAlpha(stock.properties.high, stock.properties.low, stock.properties.close, stock.properties.volume);
end

function [exposure, offsetSize] = getAlpha(high, low, close, volume)
    toCumsum = ((close - low) - (high - close)) ./(high - low).*volume ;
    originSize = size(toCumsum);
    exposure = zeros(originSize);
    for i = 0:5
        toAdd = [zeros(i, size(toCumsum, 2));toCumsum(1:end-i,:)];
        exposure = exposure + toAdd;
    end
    offsetSize = 5;
    return
end