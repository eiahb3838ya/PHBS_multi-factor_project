function X = HSIGMA(stock)
    [X,offsetSize] = getAlpha(stock.properties.totalreturns);
end

%beta zz500
function [factor offsetSize] = getAlpha(stockrts,ZZ500rts)
    [m,n]= size(stockrts);
	w = ExponentialWeight(252, 63);
    wMatrix =  repmat(w,1,n); 
    
    for i = 252:m
        wStockRts = stockrts(i-251:i,:) .* wMatrix;
        wZZ500Rts = ZZ500rts(i-251:i,:) .* w;
        beta(i,:)=(wStockRts' * wStockRts \ (wStockRts' * wZZ500Rts ))'
        res(i,:) = wZZ500Rts(i,1) - wStockRts * beta';
    end
end

