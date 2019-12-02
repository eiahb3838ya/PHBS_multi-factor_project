function X = alpha102(stock)
    X = getAlpha102(stock.volume);
end

%SMA(MAX(VOLUME-DELAY(VOLUME,1),0),6,1)/SMA(ABS(VOLUME-DELAY(VOLUME,1)),6,1)*100
function exposure = getAlpha102(volume)
     [m,n]= size(volume);
     delayVolume = [zeros(1,n);volume(1:m-1,:)];
     left = max(volume - delayVolume,0);
     
     exposure = sma(left,6,1)./sma(abs(left),6,1) * 100;
end