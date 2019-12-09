function [X, offsetSize] = alpha152(alphaPara)
% main function
% alpha152
% min data size: 66(may be smaller than 66)
% SMA(MEAN(DELAY(SMA(DELAY(CLOSE/DELAY(CLOSE,9),1),9,1),1),12)-MEAN(DELAY(SMA(DELAY(CLOSE/DELAY(CLOSE,9),1),9,1),1),26),9,1)

%     get parameters from alphaPara
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
    [m,n] = size(close);
    delayClose = [zeros(1,n);close(1:m-1,:)];
    divClose = close ./ delayClose;
    divClose(1,:) = 0; %the first line is INF, so turn INF = 0;
    delayDivClose = [zeros(1,n);divClose(1:m-1,:)];
    calSMA= SMA(delayDivClose,9,1);
    delayCalSMA = [zeros(1,n);calSMA(1:m-1,:)];
    meanDelayCalSMA = movmean(delayCalSMA,[12 0],1);
    meanDelayCalSMA2 = movmean(delayCalSMA,[26 0],1);
    
    exposure = sma(meanDelayCalSMA - meanDelayCalSMA2,9,1);
    offsetSize = 66;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end