function [X, offsetSize] = alpha083(stock)
% main function
% -1 * RANK(COVIANCE(RANK(HIGH), RANK(VOLUME), 5))
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.high, stock.volume);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, volume)
% function compute alpha
    [m, n] = size(high);
    coviance = zeros(m ,n);
    
    for j = 1: n
        for i = 1: 4
            rankHigh = sort(high(1: i, :));
            rankVolume = sort(volume(1: i, :));
            covMatrix = cov(rankHigh(1: i, j), rankVolume(1: i, j));
            coviance(i, j) = covMatrix(1, 2);
        end
        for i = 5: m
            rankHigh = sort(high(1: i, :));
            rankVolume = sort(volume(1: i, :));
            covMatrix = cov(rankHigh(i - 4: i, j), rankVolume(i - 4: i, j));
            coviance(i, j) = covMatrix(1, 2);
        end
    end
    exposure = -1 * sort(coviance);
    offsetSize = 5;
end
