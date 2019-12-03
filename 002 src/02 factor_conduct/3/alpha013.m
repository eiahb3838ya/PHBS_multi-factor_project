% (HIGH * LOW)^0.5 - VWAP

function X = alpha13(stock)
    X = getAlpha13(stock.high, stock.low, stock.vwap);
end

function exposure = getAlpha13(high, low, vwap)
    exposure = (high .* low)^0.5 - vwap;
end
