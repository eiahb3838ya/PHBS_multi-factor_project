function [X, offsetSize] = alpha052(alphaPara)
% main function
% alpha052
% min data size:27
% SUM(MAX(0,HIGH-DELAY((HIGH+LOW+CLOSE)/3,1)),26)/SUM(MAX(0,DELAY((HIGH+LOW+CLOSE)/3,1)-L),26)* 100
%     get parameters from alphaPara
    try
        high = alphaPara.high;
        low = alphaPara.low;
        close = alphaPara.close;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(high, low, close);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(high, low, close);
    end     
end

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

function [exposure, offsetSize] = getAlphaUpdate(high, low, close)
    %     return the latest index
    [X, offsetSize] = getAlpha(high, low, close);
    exposure = X(end,:);
    return
end