
function [X, offsetSize] = alpha71(alphaPara)
    %Alpha71 (CLOSE-MEAN(CLOSE,24))/MEAN(CLOSE,24)*100
    % min data size:24
    
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
    sumPast = zeros(size(close));
    for i = 0:24-1
        toAdd = [zeros(i, size(close, 2));close(1:end-i,:)];
        sumPast = sumPast + toAdd;
    end
    meanPast = sumPast/24;
    exposure = (close-meanPast)/meanPast*100;
    offsetSize = 23;
    return
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end

