function [X, offsetSize] = alpha002(alphaPara)
% main function
% alpha022
% min data size: 2
% (-1 * DELTA((((CLOSE - LOW) - (HIGH - CLOSE)) / (HIGH - LOW)), 1))

%     get parameters from alphaPara
    try
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
        [X, offsetSize] = getAlpha(high, low, close);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(high, low, close);
    end     
end

function [exposure,offsetSize] = getAlpha(close,low, high)
    [m,n]= size(close);
    daily = ((close - low)-(high - close))./(high - low + eps);
    delay = [zeros(1,n);daily(1:m-1,:)];
    
    exposure = -1 *(daily - delay);
    offsetSize = 2;
end

function [exposure, offsetSize] = getAlphaUpdate(close, low, high)
    %    return the latest index
    [X, offsetSize] = getAlpha(high, low, close);
    exposure = X(end,:);
    return
end
    
