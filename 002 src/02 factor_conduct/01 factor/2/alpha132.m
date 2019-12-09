function [X, offsetSize] = alpha132(alphaPara)
% main function
% alpha132
% min data size:20
% MEAN(AMOUNT,20)

%     get parameters from alphaPara
    try
        amount = alphaPara.amount;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(amount);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(amount);
    end     
end

function [exposure, offsetSize] = getAlpha(amount)
    exposure = movmean(amount,[20 ],1)
    offsetSize = 20;
end

function [exposure, offsetSize] = getAlphaUpdate(amount)
    %     return the latest index
    [X, offsetSize] = getAlpha(amount);
    exposure = X(end,:);
    return
end