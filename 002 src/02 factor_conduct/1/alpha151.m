% Alpha151 SMA(CLOSE-DELAY(CLOSE,20),20,1)
% first 20 not useable

close = projectData.stock.properties.close;
closeDelay = [zeros(20, size(close, 2));close(1:end-20,:)];
alpha = sma(close - closeDelay, 20, 1);