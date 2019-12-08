function [X, offsetSize] = alpha083(alphaPara, rollingWindow)
% main function
% -1 * RANK(COVIANCE(RANK(HIGH), RANK(VOLUME), 5))
% the number of ranking values is a rolling window whose length is a
% parameter rollingWindow
% min data size: rollingWindow + 4
% alphaPara is a structure
    try
        high = alphaPara.high;
        volume = alphaPara.volume;
    catch
        error 'para error';
    end

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(high, volume, rollingWindow);
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

function [exposure, offsetSize] = getAlphaUpdate(high, volume, rollingWindow)
    [m, n] = size(high);
    offsetSize = rollingWindow + 4;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    coviance = zeros(rollingWindow ,n);
    for j = 1: n
        for i = 1: rollingWindow
            rankHigh = sort(high(i: i + 4, :));
            rankVolume = sort(volume(i: i + 4, :));
            covMatrix = cov(rankHigh(i: i + 4, j), rankVolume(i: i + 4, j));
            coviance(i, j) = covMatrix(1, 2);
        end
    end
    exposure = -1 * sort(coviance);
end
