function [X, offsetSize] = alphaEx2(alphaPara)
% main function
% alpha132
% min data size:20
% MEAN(AMOUNT,20)

%     get parameters from alphaPara
    try
        
        open = alphaPara.open;
        close = alphaPara.close;
        
        
        
        updateFlag  = alphaPara.updateFlag;
        
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(open, close);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(open, close);
    end     
end

function [exposure, offsetSize] = getAlpha(open, close)
    
    exposure = open - [zeros(1, size(close, 2));close(1:end-1,:)];
    offsetSize = 1;
end

function [exposure, offsetSize] = getAlphaUpdate(open, close)
    %     return the latest index
    [X, offsetSize] = getAlpha(open, close);
    exposure = X(end,:);
    return
end
