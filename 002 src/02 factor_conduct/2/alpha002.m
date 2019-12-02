function X = alpha002(stock)
    X = getAlpha002(stock.close,stock.low,stock.high);
end

%(-1 * DELTA((((CLOSE - LOW) - (HIGH - CLOSE)) / (HIGH - LOW)), 1))
function exposure = getAlpha022(close,low,high)
    [m,n]= size(close);
    daily = ((close - low)-(high - close))./(high - low);
    delay = [zeros(1,n);daily(1:m-1,:)];
    
    exposure = -1 *(daily - delay);
end
    
