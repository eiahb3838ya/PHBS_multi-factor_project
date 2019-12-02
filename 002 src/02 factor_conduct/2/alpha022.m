function X = alpha022(stock)
    X = getAlpha022(stock.close);
end

%SMA(((CLOSE-MEAN(CLOSE,6))/MEAN(CLOSE,6)-DELAY((CLOSE-MEAN(CLOSE,6))/MEAN(CLOSE,6),3)),12,1)
function exposure = getAlpha022(close,low,high)
    [m,n] =size(close);
    meanClose = movmean(close,[6 0],1);
    closePart = (close - meanClose)./meanClose;
    delayClosePart = [zeros(3,n);closePart(1:m-3,:)];
    
    exposure = sma(closePart - delayClosePart,12,1);

end
