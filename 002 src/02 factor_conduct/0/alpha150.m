function [X, offsetSize] = alpha150(stock)
%ALPHA150, get alpha150 series from stock struct.
%         formula: (CLOSE+HIGH+LOW)/3*VOLUME 
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.

    %step 1:  get alphas
    [X, offsetSize] = getAlpha(stock.properties.close, stock.properties.high, stock.properties.low, stock.properties.volume);
    
end

function [alphaArray,offsetSize] = getAlpha(dailyClose, dailyHigh, dailyLow, dailyVolume)
%ALPHA150 (CLOSE+HIGH+LOW)/3*VOLUME 
%   OUTPUTS: offsetSize, alphaArray(offsetSize:end,:) are useful data
%   NOTE: data should be cleaned before put into the formula!
    offsetSize = 1;

    [m1, n1] = size(dailyClose);
    [m2, n2] = size(dailyHigh);
    [m3, n3] = size(dailyLow);
    [m4, n4] = size(dailyVolume);
    
    %--------------------error dealing part start-----------------------
    if sum(isnan([dailyClose, dailyHigh, dailyLow, dailyVolume]))~=0
        error 'nan exists!please check the data!'
    end

    if ~(m1==m2 && m2==m3 && m3==m4 && n1==n2 && n2==n3 && n3==n4)
        error 'size of all input matrix must match!';
    end
    %--------------------error dealing part start-----------------------

    alphaArray = (dailyClose + dailyHigh + dailyLow)/3.*dailyVolume;
    

end

