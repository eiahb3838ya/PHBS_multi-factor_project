function [X, offsetSize] = alpha102(stock)
%main function
%SMA(MAX(VOLUME-DELAY(VOLUME,1),0),6,1)/SMA(ABS(VOLUME-DELAY(VOLUME,1)),6,1)*100
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.volume);
end

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(volume)
     [m,n]= size(volume);
     delayVolume = [zeros(1,n);volume(1:m-1,:)];
     left = max(volume - delayVolume,0);
     
     exposure = sma(left,6,1)./sma(abs(left),6,1) * 100;
     offsetSize = 7;
end