% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% earnings_ttm / mkt_freeshares

function X = ETOP(stock)
    X = getETOP(stock.PE_TTM);
end

function exposure = getETOP(PE_TTM)
    exposure = 1 ./ (PE_TTM + eps);
end