function [X, offsetSize] = alpha110(alphaPara, delay, rollingWindow)
%ALPHA110 SUM(MAX(0,HIGH-DELAY(CLOSE,1)),20)/SUM(MAX(0,DELAY(CLOSE,1)-LOW),20)*100
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
    
    %set default params
    if nargin == 1
        delay = 1;
        rollingWindow = 20;
    end

    %     get parameters from alphaPara
    try
        close = alphaPara.close;
        high = alphaPara.high;
        low = alphaPara.low;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(high, close, low, delay, rollingWindow );
        return;
    else
        [X, offsetSize] = getAlphaUpdate(high, close, low, delay, rollingWindow );
    end
end

function [alphaArray, offsetSize] = getAlpha(high, close, low, delay, rollingWindow )
%ALPHA110 SUM(MAX(0,HIGH-DELAY(CLOSE,1)),20)/SUM(MAX(0,DELAY(CLOSE,1)-LOW),20)*100 
%Default: delay = 1,rollingWindow = 20
%INPUT: high,close,low,matrix of size '#days x #companies';
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies'
%
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%NOTE: data should be cleaned before put into the formula!

    if nargin == 3
        delay = 1;
        rollingWindow = 20;
    end

    %decide offset size
    offsetSize = rollingWindow;

    [m1,n1] = size(high);
    [m2,n2] = size(close);
    [m3,n3] = size(low);

    %--------------------error dealing part start-----------------------
%     if sum(isnan([high,close,low]))~=0
%         error 'nan exists!check the raw data!';
%     end

    if ~(m1==m2 && m2==m3 && n1==n2 && n2==n3)
        error 'input matrix size must match';
    end

    if rollingWindow >= m1 || delay>=rollingWindow
        error 'rolling window should be smaller than input matrix rows OR delay size should be smaller than rolling window strictly';
    end
    %--------------------error dealing part end-----------------------

    % MAX(0,HIGH-DELAY(CLOSE,1))
    % get delay close matrix
    delayClose = delayMat(close, delay);
    maxMatrix1 = max(high - delayClose,0);

    % SUM(maxMatrix1,20)
    % get rolling sum
    sumMatrix1 = rollingSum(maxMatrix1, rollingWindow);

    % MAX(0,DELAY(CLOSE,1)-LOW)
    % SUM(maxMatrix2,20)
    maxMatrix2 = max(delayClose - low, 0);
    sumMatrix2 = rollingSum(maxMatrix2, rollingWindow);

    %get result, add eps in case of zero divison
    alphaArray = 100 * sumMatrix1./(sumMatrix2+eps);

end

function [alphaArray, offsetSize] = getAlphaUpdate(high, close, low, delay, rollingWindow )
    [X, offsetSize] = getAlpha(high, close, low, delay, rollingWindow );
    alphaArray = X(end,:);
end

function delayMatrix = delayMat(rawMatrix, delay)

    ansMatrix = zeros(size(rawMatrix));
    ansMatrix(delay+1:end,:) = rawMatrix(1:end-delay,:); 

    delayMatrix = ansMatrix;
end

function rollingSum = rollingSum(rawMatrix, rollingWindow)

    [~,n] = size(rawMatrix);

    ansMatrix = zeros(size(rawMatrix));
    for col = 1:n
        ansMatrix(:,col) = movsum(rawMatrix(:,col), [rollingWindow-1,0]);
    end

    rollingSum = ansMatrix;

end

