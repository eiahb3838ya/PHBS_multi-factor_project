function [X, offsetSize] = DASTD(stock)
% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% sigma_{t=1}^{T}(w_t(r_t - \miu_t)^2)^0.5
% stock is a structure

% clean data module here

% get factor module here
    [X, offsetSize] = getDASTD(stock.properties.close, 40, 250);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getDASTD(close, halfLife, T)
% function compute factor exposure of style factor
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    r = close ./ delay - 1;
    rAdjusted = r - mean(r);
    w = ExponentialWeight(T, halfLife);
    exposure = zeros(m, n);
    for i = 1: 249
        exposure(i, :) = sum((w(1: i) .* rAdjusted(1: i, :).^2).^0.5);
    end
    for i = 250: m
        exposure(i, :) = sum((w .* rAdjusted(i - 249: i, :).^2).^0.5);
    end
    offsetSize = T;
end