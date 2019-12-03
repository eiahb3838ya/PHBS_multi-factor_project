function [X, offsetSize] = alpha70(stock, rollingWindow)
%ALPHA70 STD(AMOUNT,6) 
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
    
    %set default params
    if nargin == 1
        rollingWindow = 6;
    end

    %step 1:  get alphas
    [X, offsetSize] = getAlpha(stock.properties.amount, rollingWindow);
end

function [alphaArray, offsetSize] = getAlpha(amount, rollingWindow)
%ALPHA STD(AMOUNT,6) 
%INPUT:amount,  matrix of size '#days x #companies';
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies'
%
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%NOTE: data should be cleaned before put into the formula!

    if nargin == 1
        rollingWindow = 6;
    end

    offsetSize = rollingWindow;

    [m,n] = size(amount);

    %--------------------error dealing part start-----------------------
    if sum(isnana(amount))~=0
        error 'nan exists!'
    end

    if m <= rollingWindow || rollingWindow<=0
        error 'check input rows and rolling window size!'
    end
    %--------------------error dealing part end-----------------------

    rollingStdMatrix = zeros(m,n); 
    for col=1:n
        rollingStdMatrix(:,col) = movstd(amount(:,col), [rollingWindow-1,0]);
    end

    alphaArray = rollingStdMatrix;

end

