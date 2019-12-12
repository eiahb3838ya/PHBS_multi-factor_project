
function [X, offsetSize] = alpha171(alphaPara)
    % Alpha171 ((-1 * ((LOW - CLOSE) * (OPEN^5))) / ((CLOSE - HIGH) * (CLOSE^5))
    % min data size:1
    
    try
        open = alphaPara.open;
        high = alphaPara.high;
        low = alphaPara.low;
        close = alphaPara.close;
        updateFlag  = alphaPara.updateFlag;
        
    catch
        error 'para error';
    end
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(open, high, low, close);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(open, high, low, close);
    end
    
end

function [exposure, offsetSize] = getAlpha(open, high, low, close)
    exposure = (-1 * ((low - close) .* (open.^5))) ./ ((close - high) .* (close.^5));
    offsetSize = 0;
end

function [exposure, offsetSize] = getAlphaUpdate(open, high, low, close)
    %     return the latest index
    [X, offsetSize] = getAlpha(open, high, low, close);
    exposure = X(end,:);
    return
end





