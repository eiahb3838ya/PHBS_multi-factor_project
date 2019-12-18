function [X, offsetSize] = alpha120(alphaPara, rollingRankWindow)
%ALPHA120 RANK(VWAP - CLOSE) / RANK(VWAP + CLOSE)
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
    
    %set default params
    if nargin == 1
        rollingRankWindow = 10;
    end

    %     get parameters from alphaPara
    try
        close = alphaPara.close;
        vwap = alphaPara.vwap;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(vwap,close,rollingRankWindow);
        return;
    else
        [X, offsetSize] = getAlphaUpdate(vwap,close,rollingRankWindow);
    end
end

function [alphaArray,offsetSize] = getAlpha(vwap, dailyClose, rollingRankWindow)
%ALPHA120 RANK(VWAP - CLOSE) / RANK(VWAP + CLOSE)
%   INPUTS: vwap - volume weighted average price, size = #days x #companies
%           dailyClose - close price, size = #days x #companies
%   OUTPUTS: offsetSize, alphaArray(offsetSize:end,:) are useful data
%   NOTE: data should be cleaned before put into the formula!

    if nargin == 1
        rollingRankWindow = 0;
    end
    
    offsetSize = 1;

    [m1, n1] = size(vwap);
    [m2, n2] = size(dailyClose);

    %--------------------error dealing part start-----------------------
%     if sum(isnan([volume,vwap]))~=0
%         error 'nan exists!please check the data!';
%     end

    if ~(m1 == m2 && n1 == n2)
        error 'vwap and dailyClose should have the same size.';
    end
    %--------------------error dealing part end-----------------------

    minusMatrix = vwap - dailyClose;
    plusMatrix = vwap - dailyClose;

    alphaArray = rollingRank(minusMatrix, offsetSize, rollingRankWindow)...
        ./rollingRank(plusMatrix, offsetSize, rollingRankWindow);

end

function [alphaArray,offsetSize] = getAlphaUpdate(vwap, dailyClose, rollingRankWindow)
    [X,offsetSize] = getAlpha(vwap, dailyClose, rollingRankWindow);
    alphaArray = X(end,:);
end

