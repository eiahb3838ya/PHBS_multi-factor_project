function [X, offsetSize] = alpha112(stock)
% main function
% (SUM((CLOSE-DELAY(CLOSE,1)>0?CLOSE-DELAY(CLOSE,1):0),12)-SUM((CLOSE-DELAY(CLOSE,1)<0?ABS(CLOSE-DELAY(CLOSE,1)):0),12))
% /(SUM((CLOSE-DELAY(CLOSE,1)>0?CLOSE-DELAY(CLOSE,1):0),12)+SUM((CLOSE-DELAY(CLOSE,1)<0?ABS(CLOSE-DELAY(CLOSE,1)):0),12))*100
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.close);
end

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(close)
    [m,n] = size(close);
    delayClose = [zeros(1,n);close(1:m-1,:)];
    diffClose = close - delayClose;
    
    %A?B:C
    choice = diffClose > 0;
    ifClose = choice .* diffClose;
    
    %A?B:C
    choice2 = diffClose < 0;
    ifClose2 = choice2 .* diffClose * -1;
    
    up = movsum(ifClose - ifClose2,[12 0],1);
    down = movsum(ifClose + ifClose2,[12 0],1);
    
    exposure = up./down * 100;
    offsetSize = 13;
end
    