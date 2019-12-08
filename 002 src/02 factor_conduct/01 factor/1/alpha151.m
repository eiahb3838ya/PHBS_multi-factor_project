
function [X, offsetSize] = alpha151(updateFlag)
% Alpha151 SMA(CLOSE-DELAY(CLOSE,20),20,1)
%SMA(A, n, m) is in sma.m
%input the whole history matrix all the time, no matter update or not

    try
        close = alphaPara.close;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(close);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(close);
    end
    
end

function [exposure, offsetSize] = getAlpha(close)
    closeDelay = [zeros(20, size(close, 2));close(1:end-20,:)];
    exposure = sma(close - closeDelay, 20, 1);
    offsetSize = 21
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end


