
function [X, offsetSize] = alpha11(alphaPara)
    %alpha11
    
    try
        high = alphaPara.high;
        low = alphaPara.low;
        close = alphaPara.close;
        volume = alphaPara.volume;
    catch
        error 'para error';
    end
        
    [X, offsetSize] = getAlpha(high, low, close, volume);
    return
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
