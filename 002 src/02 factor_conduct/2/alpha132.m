function X = alpha132(stock)
    X = getAlpha132(stock.amount);
end

%MEAN(AMOUNT,20)
function exposure = getAlpha132(amount)
    exposure = movmean(amount,[20 ],1)
end