function [X, offsetSize] = alphaEx3(alphaPara, delay)
% main function
% alpha132
% min data size:20
% MEAN(AMOUNT,20)

%     get parameters from alphaPara
    try
        
        volume = alphaPara.volume;
        updateFlag  = alphaPara.updateFlag;
        if nargin == 1
            delay = 5;
        end
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(volume, delay);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(volume, delay);
    end     
end

function [exposure, offsetSize] = getAlpha(volume, delay)
    
    exposure = (-1*volume)./sumPast(volume,delay)/delay;
    offsetSize = 6;
end

function [exposure, offsetSize] = getAlphaUpdate(volume, delay)
    %     return the latest index
    [X, offsetSize] = getAlpha(volume, delay);
    exposure = X(end,:);
    return
end
