function [X, offsetSize] = alpha100(stock, rollingWindow)
%ALPHA110 SUM(MAX(0,HIGH-DELAY(CLOSE,1)),20)/SUM(MAX(0,DELAY(CLOSE,1)-LOW),20)*100
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
    
    %set default params
    if nargin == 1
        rollingWindow = 20;
    end

    %step 1:  get alphas
    [X, offsetSize] = getAlpha(stock.volume, rollingWindow);
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
    if sum(isnan(volume))~=0
        error 'nan exists!please check the data!';
    end

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

