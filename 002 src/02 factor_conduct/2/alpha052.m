function X = alpha052(stock)
    X = getAlpha052(stock.high,stock.close,stock.low);
end

%SUM(MAX(0,HIGH-DELAY((HIGH+LOW+CLOSE)/3,1)),26)/SUM(MAX(0,DELAY((HIGH+LOW+CLOSE)/3,1)-L),26)* 100
function exposure = getAlpha052(close,low,high)
    [m,n]= size(close);
    calHighLowClose = (high + low + close)./3;
    delayCal = [zeros(1,n);calHighLowClose(1:m-1,:)];
    leftPart = max(0,high - delayCal);
    sumLeftPart = movsum(leftPart,[26 0],1);
    rightPart = leftPart - low;
    sumRightPart = movsum(rightPart,[26 0],1);
    
    exposure = sumLeftPart./sumRightPart * 100;
    
end