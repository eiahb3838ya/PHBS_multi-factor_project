function X = alpha042(stock)
    X = getAlpha042(stock.high,stock.volume);
end

%((-1 * RANK(STD(HIGH, 10))) * CORR(HIGH, VOLUME, 10))
function exposure = getAlpha042(high,volume)
    [m,n] = size(high);
    calMoveStd = movstd(high,[10 0],1);
    rankHigh = sort(calMoveStd,1);
    corrValue = movecoef(high,volume,10);
    
    exposure = -1 * rankHigh .* corrValue;   
end