% ((20 - LOWDAY(LOW, 20)) / 20) * 100

function X = alpha103(stock)
    X = getAlpha103(stock.low);
end

function exposure = getAlpha103(low)
    exposure = (20 - lowday(low, 20))./ 20.* 100;
end