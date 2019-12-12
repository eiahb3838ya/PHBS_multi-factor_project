function [X, offsetSize] = alpha160(alphaPara, rollingWindow, delay, nSMA, mSMA)
%ALPHA160, get alpha160 series from stock struct.
%         formula: SMA((CLOSE<=DELAY(CLOSE,1)?STD(CLOSE,20):0),20,1) 
%         Default: rollingWindow = 20, delay = 1, nSMA = 20, mSMA = 1
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.

    %set default params
    if nargin == 1
        rollingWindow = 20; 
        delay = 1; 
        nSMA = 20; 
        mSMA = 1;
    end

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
        [X, offsetSize] = getAlpha(close, rollingWindow, delay, nSMA, mSMA);
        return;
    else
        [X, offsetSize] = getAlphaUpdate(close, rollingWindow, delay, nSMA, mSMA);
    end
    
end


function [alphaArray, offsetSize] = getAlpha(dailyClose, rollingWindow, delay, nSMA, mSMA)
%ALPHA160 SMA((CLOSE<=DELAY(CLOSE,1)?STD(CLOSE,20):0),20,1) 
%   Default: rollingWindow = 20, delay = 1, nSMA = 20, mSMA = 1
%   INPUTS: SMA(A,n,m): Y(i+1) = (Ai*m + Yi(n-m))/n 
%           dailyClose - close price, size = #days x #companies
%   OUTPUTS: offsetSize, alphaArray(offsetSize:end,:) are useful data
%   NOTE: data should be cleaned before put into the formula!

    %set default params
    if nargin == 1
        rollingWindow = 20; 
        delay = 1; 
        nSMA = 20; 
        mSMA = 1;
    end
    
    %get offset size
    offsetSize = rollingWindow;
    [m,n] = size(dailyClose);
    
    %--------------------error dealing part start-----------------------
    if m < offsetSize
        error 'observation size insufficient, should be >= rolling window size!';
    end

    if delay >= rollingWindow
        disp('delay is recommended to be smaller than rolling window. Some results after offset size should be used with caution!');
    end

    if delay >= m
        error 'delay number should be strictly smaller than rows of dailyClose!';
    end

    if sum(isnan(dailyClose))~=0
        error 'nan exists!please check dailyClose matrix!';
    end

    if rollingWindow <= 0
        error 'rolling window should be strictly greater than 0!';
    end

    if mSMA >= nSMA
        disp('mSMA is recomended to be strictly smaller than nSMA!');
    end
    %--------------------error dealing part end-----------------------

    %DELAY(CLOSE,1)
    delayClose = zeros(m,n);
    delayClose(delay+1:end,:) = dailyClose(1:end-delay,:);

    %make a choice matrix, 1 means STD(CLOSE,20), 0 means 0
    choiceMatrix = delayClose - dailyClose;
    choiceMatrix = choiceMatrix >= 0;

    %make a std(close,20) matrix
    rollingStdMatrix = zeros(m,n);
    for col = 1:n
        rollingStdMatrix(:,col) = movstd(dailyClose(:,col), [rollingWindow-1,0]);
    end

    %execute A?B:C
    ifMatrix = choiceMatrix .* rollingStdMatrix;

    %SMA
    alphaArray = SMA(ifMatrix, nSMA, mSMA);
    
end

function [alphaArray, offsetSize] = getAlphaUpdate(dailyClose, rollingWindow, delay, nSMA, mSMA)
    [X, offsetSize] = getAlpha(dailyClose, rollingWindow, delay, nSMA, mSMA);
    alphaArray = X(end,:);
end

function sma = SMA(ts, nSMA, mSMA)
    %a function, used to calculate SMA of a time series
    [timeLength, obsObjNumber] = size(ts);

    if timeLength <= 0 || obsObjNumber <1
        error 'time series is null!';
    end

    Y = zeros(timeLength, obsObjNumber); %prepare a vector to record result

    for time = 1:timeLength
        if time == 1 || time == 2
            Y(time,:) = ts(1,:);
        else
            Y(time,:) = (ts(time-1,:)*mSMA + Y(time-1,:)*(nSMA - mSMA))/nSMA;
        end
    end

    sma = Y;

end
