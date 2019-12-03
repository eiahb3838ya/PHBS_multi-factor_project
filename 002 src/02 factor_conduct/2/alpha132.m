function [X, offsetSize] = alpha132(stock)
% main function
% MEAN(AMOUNT,20)
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.amount);
end

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(amount)
    exposure = movmean(amount,[20 ],1)
    offsetSize = 20;
end