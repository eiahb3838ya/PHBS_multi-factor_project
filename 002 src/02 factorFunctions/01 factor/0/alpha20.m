function [X, offsetSize] = alpha20(alphaPara)
%ALPHA20 (CLOSE-DELAY(CLOSE,6))/DELAY(CLOSE,6)*100
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.

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
        return;
    else
        [X, offsetSize] = getAlphaUpdate(close);
    end
end

function [alphaArray, offsetSize] = getAlpha(dailyClose)
%ALPHA020 (CLOSE-DELAY(CLOSE,6))/DELAY(CLOSE,6)*100 
%INPUT:dailyClose, matrix of size 'days x #companies';
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies', where
%'first offsetSize x #companies' are zeros.
%
%        offsetSize -- difference btw. valid output rows and raw input rows
%Note: all data should be cleaned before been put into formula!

    offsetSize = 6;
    [m,n] = size(dailyClose);
    if m < 7
        error 'more than 6 days of observation is required!'
    end

    %get delay(close, 6)
    delayMatrix = zeros(m,n);
    delayMatrix(offsetSize+1:end,:) = dailyClose(1:end-offsetSize,:); 

    %get (CLOSE-DELAY(CLOSE,6))
    diffMatrix = dailyClose - delayMatrix;

    %add epsilon in case of 0 division
    alphaArray = diffMatrix./(delayMatrix+eps)*100;

end

function [alphaArray, offsetSize] = getAlphaUpdate(dailyClose)
    [X, offsetSize] = getAlpha(dailyClose);
    alphaArray = X(end,:);
end
