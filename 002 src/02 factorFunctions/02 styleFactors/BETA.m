% function [X, offsetSize] = BETA(stock)
% % Computed as the slope coefficient in a time-series reg of excess stock return.
% % the benchmark is zz500.
% % r_t = alpha + beta * R_t +eplison
% % stock is a structure
% 
% % clean data module here
% 
% % get factor module here
%     [X, offsetSize] = getAlpha(stock.properties.totalReturn;
%                               stock.index.totalReturn[:,7]);
% end
% 
% %-------------------------------------------------------------------------
% function [exposure, offsetSize] = getAlpha(stockrts,ZZ500rts)
%     [m,n]= size(stockrts);
%     w = ExponentialWeight(252, 63);
%     wMatrix = repmat(w,1,n); 
%     
%     for i = 252:m
%         wStockRts = stockrts(i-251:i,:) .* wMatrix;
%         wZZ500Rts = ZZ500rts(i-251:i,:) .* w;
%         toCell =mat2cell(wStockRts,252,[ones(1,n)]);
%         B =blkdiag(toCell{:});%diag each column of the wStockRts
%         Y = repmat(wZZ500Rts,n,1);
%         beta(i,:) = ( B' * B \( B' * Y ))';
%     end
%     
%     exposure = beta;
%     offsetSize = 521;
% end

function [X, offsetSize] = BETA(alphaPara)
% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% earnings_ttm / mkt_freeshares
% min data size: 1
% alphaPara is a structure
    try
        totalReturn = alphaPara.totalReturn;
        indexTotalReturn  = alphaPara.indexTotalReturn;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getBETA(totalReturn, indexTotalReturn);
        return
    else
        [X, offsetSize] = getBETAUpdate(totalReturn, indexTotalReturn);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getBETA(stockrts,ZZ500rts)
% function compute factor exposure of style factor
    [m,n]= size(stockrts);
    w = ExponentialWeight(252, 63);
    wMatrix = repmat(w,1,n); 
    
    for i = 252:m
        wStockRts = stockrts(i-251:i,:) .* wMatrix;
        wZZ500Rts = ZZ500rts(i-251:i,:) .* w;
        toCell =mat2cell(wStockRts,252,[ones(1,n)]);
        
        B =blkdiag(toCell{:});%diag each column of the wStockRts
        
        Y = repmat(wZZ500Rts,n,1);
        beta(i,:) = ( B' * B \( B' * Y ))';
    end
    
    exposure = beta;
    offsetSize = 521;
end

function [exposure, offsetSize] = getBETAUpdate(stockrts,ZZ500rts)
    [X, offsetSize] = getBETA(stockrts,ZZ500rts);
    exposure = X(end,:);
end
        
    
