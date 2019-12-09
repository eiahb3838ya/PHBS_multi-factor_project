function [X, offsetSize] = alpha042(alphaPara)
% main function
% alpha042
% min data size:10
% ((-1 * RANK(STD(HIGH, 10))) * CORR(HIGH, VOLUME, 10))

    %     get parameters from alphaPara
    try
        high = alphaPara.high;
        volume = alphaPara.volume;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(high, volume);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(high, volume);
    end     
end

function [exposure,offsetSize] = getAlpha(high,volume)
    [m,n] = size(high);
    calMoveStd = movstd(high,[10 0],1);   
    rankHigh = rollingRank(calMoveStd,10,20);
    corrValue = movecoef(high,volume,10);
   
    exposure = -1 * rankHigh .* corrValue;  
    offsetSize = 10;
end

function [exposure, offsetSize] = getAlphaUpdate(high, volume)
    %     return the latest index
    [X, offsetSize] = getAlpha(high, volume);
    exposure = X(end,:);
    return
end