% ((20 - HIGHDAY(HIGH, 20)) / 20) * 100 - ((20 - LOWDAY(LOW, 20)) / 20) * 100

function X = alpha133(stock)
    X = getAlpha133(stock.high, stock.low);
end

function exposure = getAlpha133(high, low)
    exposure = (20 - highday(high, 20))./ 20.* 100 - (20 - lowday(low, 20))./ 20.* 100;
end