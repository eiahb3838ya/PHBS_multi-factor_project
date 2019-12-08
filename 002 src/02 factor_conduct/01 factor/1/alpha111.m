



function [X, offsetSize] = alpha111(alphaPara)
%Alpha11 SMA(VOL*((CLOSE-LOW)-(HIGH-CLOSE))/(HIGH-LOW),11,2)-SMA(VOL*((CLOSE-LOW)-(HIGH-CLOSE))/(HIGH-LOW),4,2)
%SMA(A, n, m) is in sma.m
%input the whole history matrix all the time, no matter update or not
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
   
%     [X, offsetSize] = getAlpha(stock.properties.high, stock.properties.low, stock.properties.close, stock.properties.volume);
end

function [exposure, offsetSize] = getAlpha(high, low, close, volume)
    A = volume.*((close - low) - (high - close))./(high - low);
    exposure = sma(A, 11, 2) - sma(A, 4, 2);
    offsetSize = 1;
end

function [exposure, offsetSize] = getAlphaUpdate(high, low, close, volume)
    %     return the latest index
    [X, offsetSize] = getAlpha(high, low, close, volume);
    exposure = X(end,:);
    return
end



