
function [X, offsetSize] = alpha161(alphaPara)
    % Alpha161 MEAN(MAX(MAX((HIGH-LOW),ABS(DELAY(CLOSE,1)-HIGH)),ABS(DELAY(CLOSE,1)-LOW)),12)
    % min data size:13
    
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

function [exposure, offsetSize] = getAlpha(high, low, close)
    closeDelay = [zeros(1, size(close, 2));close(1:end-1,:)];
    A = max(max(high-low,abs(closeDelay-high)),abs(closeDelay-low));
    sumPast = zeros(size(A));
    for i = 0:12-1
        toAdd = [zeros(i, size(A, 2));A(1:end-i,:)];
        sumPast = sumPast + toAdd;
    end
    exposure = sumPast/12;
    offsetSize = 12;
end

function [exposure, offsetSize] = getAlphaUpdate(high, low, close)
    %     return the latest index
    [X, offsetSize] = getAlpha(high, low, close);
    exposure = X(end,:);
    return
end



