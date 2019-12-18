function [X, offsetSize] = alpha100(alphaPara, rollingWindow)
%ALPHA100 STD(VOLUME,20) 
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
    
    %set default params
    if nargin == 1
        rollingWindow = 20;
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
        [X, offsetSize] = getAlpha(volume, rollingWindow);
        return;
    else
        [X, offsetSize] = getAlphaUpdate(volume, rollingWindow);
    end
end

function [alphaArray,offsetSize] = getAlpha(volume, rollingWindow)
%ALPHA100 STD(VOLUME,20) 
%   volume,size = #days x #companies
%   OUTPUTS: offsetSize, alphaArray(offsetSize:end,:) are useful data
%   NOTE: data should be cleaned before put into the formula!

    if nargin == 1
        rollingWindow = 20;
    end

    offsetSize = rollingWindow;

    [m,n] = size(volume);

    %--------------------error dealing part start-----------------------
%     if sum(isnan(volume))~=0
%         error 'nan exists!please check the data!';
%     end

    if rollingWindow <= 0
        error 'rolling window should be greater than 0(strictly)';
    end 

    if rollingWindow > m
        error 'rolling window should not be greater than rows of input matrix!';
    end
    %--------------------error dealing part end-----------------------

    %get rolling standard deviation
    rollingStdMatrix = zeros(m,n);
    for col = 1:n
        rollingStdMatrix(:,col) = movstd(volume(:,col), [rollingWindow-1,0]);
    end

    alphaArray = rollingStdMatrix;

end

function [alphaArray,offsetSize] = getAlphaUpdate(volume, rollingWindow)
    [X,offsetSize] = getAlpha(volume, rollingWindow);
    alphaArray = X(end,:);
end