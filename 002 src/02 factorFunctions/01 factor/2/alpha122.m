function [X, offsetSize] = alpha122(alphaPara)
% main function
% alpha122
% min data size:20
%(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2)-DELAY(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2),1))
%/DELAY(SMA(SMA(SMA(LOG(CLOSE),13,2),13,2),13,2),1)

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

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(close)
    [m,n] = size(close);
    firstSMA = sma(log(close),13,2);
    secondSMA = sma(firstSMA,13,2);
    thirdSMA = sma(secondSMA,13,2);
    delaySMA = [zeros(1,n);thirdSMA(1:m-1,:)];
    
    exposure = (thirdSMA - delaySMA +eps )./(delaySMA +eps);
    offsetSize = 20;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    %     return the latest index
    [X, offsetSize] = getAlpha(close);
    exposure = X(end,:);
    return
end