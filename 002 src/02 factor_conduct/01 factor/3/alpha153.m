function [X, offsetSize] = alpha153(alphaPara)
% main function
% (MEAN(CLOSE, 3) + MEAN(CLOSE, 6) + MEAN(CLOSE, 12) + MEAN(CLOSE, 24)) / 4
% min data size: 24
% alphaPara is a structure
    try
        close = alphaPara.close;
    catch
        error 'para error';
    end

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(close);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(close)
% function compute alpha
    [m, n] = size(close);
    MA3 = zeros(m, n);
    MA6 = zeros(m, n);
    MA12 = zeros(m, n);
    MA24 = zeros(m, n);
    for i = 1: 2
        MA3(i, :) = mean(close(1: i, :), 'omitnan');
    end
    for i = 3: m
        MA3(i, :) = mean(close(i - 2: i, :), 'omitnan');
    end
    for i = 1: 5
        MA6(i, :) = mean(close(1: i, :), 'omitnan');
    end
    for i = 6: m
        MA6(i, :) = mean(close(i - 5: i, :), 'omitnan');
    end
    for i = 1: 11
        MA12(i, :) = mean(close(1: i, :), 'omitnan');
    end
    for i = 12: m
        MA12(i, :) = mean(close(i - 11: i, :), 'omitnan');
    end
    for i = 1: 23
        MA24(i, :) = mean(close(1: i, :), 'omitnan');
    end
    for i = 24: m
        MA24(i, :) = mean(close(i - 23: i, :), 'omitnan');
    end
    exposure = (MA3 + MA6 + MA12 + MA24)./ 4;
    offsetSize = 24;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    [m, ~] = size(close);
    offsetSize = 24;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    MA3 = mean(close(m - 2: m, :));
    MA6 = mean(close(m - 5: m, :));
    MA12 = mean(close(m - 11: m, :));
    MA24 = mean(close(m - 23: m, :));
    exposure = (MA3 + MA6 + MA12 + MA24)./ 4;
end