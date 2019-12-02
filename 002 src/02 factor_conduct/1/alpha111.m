%Alpha111
%SMA(VOL*((CLOSE-LOW)-(HIGH-CLOSE))/(HIGH-LOW),11,2)-SMA(VOL*((CLOSE-LOW)-(HIGH-CLOSE))/(HIGH-L
%OW),4,2)

close = projectData.stock.properties.close;
low = projectData.stock.properties.low;
high = projectData.stock.properties.high;
volume = projectData.stock.properties.volume;

A = volume.*((close - low) - (high - close))./(high - low);
alpha = sma(A, 11, 2) - sma(A, 4, 2);

