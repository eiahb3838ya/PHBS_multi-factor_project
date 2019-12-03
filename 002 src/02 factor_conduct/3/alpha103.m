function [X, offsetSize] = alpha103(stock)
% main function
% ((20 - LOWDAY(LOW, 20)) / 20) * 100
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.properties.low);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(low)
% function compute alpha
    exposure = (20 - lowday(low, 20))./ 20.* 100;
    offsetSize = 20;
end