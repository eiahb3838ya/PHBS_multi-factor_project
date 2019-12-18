function [X, offsetSize] = alpha80(alphaPara, delay)
%ALPHA080 (VOLUME-DELAY(VOLUME,5))/DELAY(VOLUME,5)*100
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
    
    %set default params
    if nargin == 1
        delay = 5;
    end

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
        [X, offsetSize] = getAlpha(volume, delay);
        return;
    else
        [X, offsetSize] = getAlphaUpdate(volume, delay);
    end
end

function [alphaArray, offsetSize] = getAlpha(volume, delay)
%ALPHA080 (VOLUME-DELAY(VOLUME,5))/DELAY(VOLUME,5)*100
%INPUT: volume,matrix of size '#days x #companies';
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies'
%
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%NOTE: data should be cleaned before put into the formula!

    if nargin == 1
        delay = 5;
    end

    offsetSize = delay;
    [m,~] = size(volume);
    
    %--------------------error dealing part start-----------------------
%     if sum(isnan(volume))~=0
%         error 'nan exists!check the raw data!';
%     end

    if m < offsetSize
        error 'more than 5 days of observation is required!'
    end
    %--------------------error dealing part end-----------------------

    %get DELAY(VOLUME,5)
    delayMatrix = delayMat(volume, delay);

    %get VOLUME-DELAY(VOLUME,5)
    diffMatrix = volume - delayMatrix;

    % diffMatrix/delayMatrix*100
    %add epsilon in case of 0 division
    alphaArray = 100*diffMatrix ./ (delayMatrix + eps);

end

function [alphaArray, offsetSize] = getAlphaUpdate(volume, delay)
    [X, offsetSize] = getAlpha(volume, delay);
    alphaArray = X(end,:); 
end

function delayMatrix = delayMat(rawMatrix, delay)

    ansMatrix = zeros(size(rawMatrix));
    ansMatrix(delay+1:end,:) = rawMatrix(1:end-delay,:); 

    delayMatrix = ansMatrix;
end
