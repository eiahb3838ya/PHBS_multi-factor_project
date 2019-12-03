function [X, offsetSize] = alpha002(stock)
% main function
% (-1 * DELTA((((CLOSE - LOW) - (HIGH - CLOSE)) / (HIGH - LOW)), 1))
% stock is a structure

% clean data module here

% get alpha module here
    [X,offsetSize] = getAlpha(stock.properties.close,
                              stock.properties.low,
                              stock.properties.high);
end

%-------------------------------------------------------------------------
function [exposure,offsetSize] = getAlpha(close,low,high)
    [m,n]= size(close);
    daily = ((close - low)-(high - close))./(high - low);
    delay = [zeros(1,n);daily(1:m-1,:)];
    
    exposure = -1 *(daily - delay);
    offsetSize = 2;
end
    
