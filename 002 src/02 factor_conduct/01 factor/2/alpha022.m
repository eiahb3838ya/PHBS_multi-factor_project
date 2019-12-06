function X = alpha022(stock)
% main function
% SMA(((CLOSE-MEAN(CLOSE,6))/MEAN(CLOSE,6)-DELAY((CLOSE-MEAN(CLOSE,6))/MEAN(CLOSE,6),3)),12,1)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.close);
end

%-------------------------------------------------------------------------
function [exposure offsetSize] = getAlpha(close)
    [m,n] =size(close);
    meanClose = movmean(close,[6 0],1);
    closePart = (close - meanClose)./meanClose;
    delayClosePart = [zeros(3,n);closePart(1:m-3,:)];
    
    exposure = sma(closePart - delayClosePart,12,1);
    offsetSize = 20;
end
