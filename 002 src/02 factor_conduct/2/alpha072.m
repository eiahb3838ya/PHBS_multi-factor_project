function X = alpha072(stock)
    X = getAlpha072(stock.high,stock.close,stock.low);
end

%SMA((TSMAX(HIGH,6)-CLOSE)/(TSMAX(HIGH,6)-TSMIN(LOW,6))*100,15,1)
function exposure = getAlpha072(low,high,close)
    left = movmax(high,[6 ],1) - close
    right = movmax(high,[6 ],1) - movmin(low,[6 ],1)
    
    exposure = sma(left./right * 100 ,15,1)
end