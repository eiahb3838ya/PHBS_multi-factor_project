function [X, offsetSize] = DASTD(alphaPara)
% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% sigma_{t=1}^{T}(w_t(r_t - \miu_t)^2)^0.5
% min data size: 251
% alphaPara is a structure
    try
        close = alphaPara.close;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getDASTD(close, 40, 250);
        return
    else
        [X, offsetSize] = getDASTDUpdate(close, 40, 250);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getDASTD(close, halfLife, T)
% function compute factor exposure of style factor
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    r = close ./ delay - 1;
    rAdjusted = r - mean(r, 2, 'omitnan');
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

function [exposure, offsetSize] = getDASTDUpdate(close, halfLife, T)
    [m, ~] = size(close);
    offsetSize = T + 1;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    delay = close(m - offsetSize : m - 1,:);
    closeTable = close(m - offsetSize + 1: m, :);
    r = closeTable ./ delay - 1;
    rAdjusted = r - mean(r, 2, 'omitnan');
    w = ExponentialWeight(T, halfLife);
    exposure = sum((w .* rAdjusted.^2).^0.5);
end