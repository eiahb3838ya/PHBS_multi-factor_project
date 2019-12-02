function X = alpha122(stock)
    X = getAlpha122(stock.close);
end

%(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2)-DELAY(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2),1))
%/DELAY(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2),1)
function exposure = getAlpha122(close)
    [m,n] = size(close);
    firstSMA = sma(log(close),13,2);
    secondSMA = sma(firstSMA,13,2);
    thirdSMA = sma(secondSMA,13,2);
    delaySMA = [zeros(1,n);thridSMA(1:m-1,:)];
    
    exposure = (thirdSMA - delaySMA)./delaySMA;
end