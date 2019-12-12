%Alpha31 (CLOSE-MEAN(CLOSE,12))/MEAN(CLOSE,12)*100


function [X, offsetSize] = alpha31(alphaPara)
    %Alpha31 (CLOSE-MEAN(CLOSE,12))/MEAN(CLOSE,12)*100
    % min data size:12
    
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
    for i = 0:11
        toAdd = [zeros(i, size(close, 2));close(1:end-i,:)];
        sumPast = sumPast + toAdd;
    end
    meanPast = sumPast/12;
    exposure = (close-meanPast)/meanPast*100;
    offsetSize = 11;
    return
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end


