function [X, offsetSize] = alpha052(stock)
%main function
%SMA((TSMAX(HIGH,6)-CLOSE)/(TSMAX(HIGH,6)-TSMIN(LOW,6))*100,15,1)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.high,
                               stock.properties.close,
                               stock.properties.low);
end

%-------------------------------------------------------------------------
function [exposure,offsetSize] = getAlpha(high,close,low)
    left = movmax(high,[6 ],1) - close
    right = movmax(high,[6 ],1) - movmin(low,[6 ],1)
    
    exposure = sma(left./right * 100 ,15,1)
    offsetSize = 21;
end