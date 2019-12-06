function [X, offsetSize] = alpha122(stock)
% main function
%(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2)-DELAY(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2),1))
%/DELAY(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2),1)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.close);
end

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(close)
    [m,n] = size(close);
    firstSMA = sma(log(close),13,2);
    secondSMA = sma(firstSMA,13,2);
    thirdSMA = sma(secondSMA,13,2);
    delaySMA = [zeros(1,n);thridSMA(1:m-1,:)];
    
    exposure = (thirdSMA - delaySMA)./delaySMA;
    offsetSize = 20;
end