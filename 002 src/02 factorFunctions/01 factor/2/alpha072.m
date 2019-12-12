function [X, offsetSize] = alpha072(alphaPara)
%main function
%alpha72
%min data size:21
%SMA((TSMAX(HIGH,6)-CLOSE)/(TSMAX(HIGH,6)-TSMIN(LOW,6))*100,15,1)

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

function [exposure,offsetSize] = getAlpha(high,close,low)
    left = movmax(high,[6 ],1) - close
    right = movmax(high,[6 ],1) - movmin(low,[6 ],1)
    
    exposure = sma(left./(right+eps) * 100 ,15,1)
    offsetSize = 21;
end

function [exposure, offsetSize] = getAlphaUpdate(high, low, close)
    %     return the latest index
    [X, offsetSize] = getAlpha(high, low, close);
    exposure = X(end,:);
    return
end