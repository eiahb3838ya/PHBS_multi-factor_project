function [X, offsetSize] = alpha052(stock)
% main function
% SUM(MAX(0,HIGH-DELAY((HIGH+LOW+CLOSE)/3,1)),26)/SUM(MAX(0,DELAY((HIGH+LOW+CLOSE)/3,1)-L),26)* 100
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.high,
                               stock.properties.close,
                               stock.properties.low);
end

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(high,close,low)
    [m,n]= size(close);
    calHighLowClose = (high + low + close)./3;
    delayCal = [zeros(1,n);calHighLowClose(1:m-1,:)];
    leftPart = max(0,high - delayCal);
    sumLeftPart = movsum(leftPart,[26 0],1);
    rightPart = leftPart - low;
    sumRightPart = movsum(rightPart,[26 0],1);
    
    exposure = sumLeftPart./sumRightPart * 100;
    offsetSize = 27;
end