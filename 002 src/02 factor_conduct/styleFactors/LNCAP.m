% Returns the log value of the total market capital of single stocks

function X = LNCAP(stock)
    X = getLNCAP(stock.totalMktCap);
end

function exposure = getLNCAP(totalMktCap)
    exposure = log(totalMktCap);
end