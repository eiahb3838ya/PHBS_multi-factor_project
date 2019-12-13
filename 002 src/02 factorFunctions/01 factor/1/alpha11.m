
function [X, offsetSize] = alpha11(alphaPara)
%   alpha11
%   min data size:6
    
    %     get parameters from alphaPara
    try
        high = alphaPara.high;
        low = alphaPara.low;
        close = alphaPara.close;
        volume = alphaPara.volume;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(high, low, close, volume);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(high, low, close, volume);
    end     
end


function [exposure, offsetSize] = getAlpha(high, low, close, volume)
    toCumsum = ((close - low) - (high - close)) ./(high - low + eps).*volume ;
    originSize = size(toCumsum);
    exposure = zeros(originSize);
    for i = 0:5
        toAdd = [zeros(i, size(toCumsum, 2));toCumsum(1:end-i,:)];
        exposure = exposure + toAdd;
    end
    offsetSize = 5;
    return
end


function [exposure, offsetSize] = getAlphaUpdate(high, low, close, volume)
    %     return the latest index
    [X, offsetSize] = getAlpha(high, low, close, volume);
    exposure = X(end,:);
    return
end
