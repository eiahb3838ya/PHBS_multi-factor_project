function [X, offsetSize] = alpha022(alphaPara)
% main function
% alpha022
% min data size: 12
% SMA(((CLOSE-MEAN(CLOSE,6))/MEAN(CLOSE,6)-DELAY((CLOSE-MEAN(CLOSE,6))/MEAN(CLOSE,6),3)),12,1)

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
    [m,n] =size(close);
    meanClose = movmean(close,[6 0],1);
    closePart = (close - meanClose)./(meanClose +eps);
    delayClosePart = [zeros(3,n);closePart(1:m-3,:)];
    
    exposure = sma(closePart - delayClosePart,12,1);
    offsetSize = 12;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end
