function X = alpha042(stock)
% main function
% ((-1 * RANK(STD(HIGH, 10))) * CORR(HIGH, VOLUME, 10))
% stock is a structure

% clean data module here

% get alpha module here
    [X,offsetSize] = getAlpha(stock.properties.high,
                              stock.properties.volume);
end

%-------------------------------------------------------------------------
function [exposure,offsetSize] = getAlpha(high,volume)
    [m,n] = size(high);
    calMoveStd = movstd(high,[10 0],1);
    rankHigh = sort(calMoveStd,1);
    corrValue = movecoef(high,volume,10);
   
    exposure = -1 * rankHigh .* corrValue;  
    offsetSize = 10;
end