function [X, offsetSize] = alpha102(alphaPara)
% main function
% alpha102
% min data size:7
% SMA(MAX(VOLUME-DELAY(VOLUME,1),0),6,1)/SMA(ABS(VOLUME-DELAY(VOLUME,1)),6,1)*100

%     get parameters from alphaPara
    try
        volume = alphaPara.volume;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(volume);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(volume);
    end      
end

function [exposure, offsetSize] = getAlpha(volume)
     [m,n]= size(volume);
     delayVolume = [zeros(1,n);volume(1:m-1,:)];
     left = max(volume - delayVolume,0);
     delayMatrix = volume - delayVolume;
     
     exposure = sma(left,6,1)./(sma(abs(delayMatrix),6,1)+eps);
     offsetSize = 7;
end

function [exposure, offsetSize] = getAlphaUpdate(volume)
    %     return the latest index
    [X, offsetSize] = getAlpha(volume);
    exposure = X(end,:);
    return
end