function [X, offsetSize] = alpha112(alphaPara)
% main function
% alpha112
% min data size:13
% (SUM((CLOSE-DELAY(CLOSE,1)>0?CLOSE-DELAY(CLOSE,1):0),12)-SUM((CLOSE-DELAY(CLOSE,1)<0?ABS(CLOSE-DELAY(CLOSE,1)):0),12))
% /(SUM((CLOSE-DELAY(CLOSE,1)>0?CLOSE-DELAY(CLOSE,1):0),12)+SUM((CLOSE-DELAY(CLOSE,1)<0?ABS(CLOSE-DELAY(CLOSE,1)):0),12))*100

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
    diffClose = close - delayClose;
    
    %A?B:C
    choice = diffClose > 0;
    ifClose = choice .* diffClose;
    
    %A?B:C
    choice2 = diffClose < 0;
    ifClose2 = choice2 .* diffClose * -1;
    
    up = movsum(ifClose - ifClose2,[12 0],1);
    down = movsum(ifClose + ifClose2,[12 0],1);
    
    exposure = up./(down+eps) * 100;
    offsetSize = 13;
end
    
function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end
