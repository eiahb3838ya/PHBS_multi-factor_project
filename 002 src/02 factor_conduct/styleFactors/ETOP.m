function [X, offsetSize] = ETOP(stock)
% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% earnings_ttm / mkt_freeshares
% stock is a structure

% clean data module here

% get factor module here
    [X, offsetSize] = getETOP(stock.PE_TTM);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getETOP(PE_TTM)
% function compute factor exposure of style factor
    exposure = 1 ./ (PE_TTM + eps);
    offsetSize = 1;
end