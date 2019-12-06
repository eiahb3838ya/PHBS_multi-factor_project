function [X, offsetSize] = alpha152(stock)
% main function
%SMA(MEAN(DELAY(SMA(DELAY(CLOSE/DELAY(CLOSE,9),1),9,1),1),12)-MEAN(DELAY(SMA(DELAY(CLOSE/DELAY(CLOSE,9),1),9,1),1),26),9,1)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.close);
end

%-------------------------------------------------------------------------
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
    offsetSize = 45;
end