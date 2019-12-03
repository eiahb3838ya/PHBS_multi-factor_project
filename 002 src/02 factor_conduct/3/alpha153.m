function [X, offsetSize] = alpha153(stock)
% main function
% (MEAN(CLOSE, 3) + MEAN(CLOSE, 6) + MEAN(CLOSE, 12) + MEAN(CLOSE, 24)) / 4
% stock is a structure

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(stock.close);
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
        MA3(i, :) = mean(sum(close(1: i, :), 'omitnan'));
    end
    for i = 3: m
        MA3(i, :) = mean(sum(close(i - 2: i, :), 'omitnan'));
    end
    for i = 1: 5
        MA6(i, :) = mean(sum(close(1: i, :), 'omitnan'));
    end
    for i = 6: m
        MA6(i, :) = mean(sum(close(i - 5: i, :), 'omitnan'));
    end
    for i = 1: 11
        MA12(i, :) = mean(sum(close(1: i, :), 'omitnan'));
    end
    for i = 12: m
        MA12(i, :) = mean(sum(close(i - 11: i, :), 'omitnan'));
    end
    for i = 1: 23
        MA24(i, :) = mean(sum(close(1: i, :), 'omitnan'));
    end
    for i = 24: m
        MA24(i, :) = mean(sum(close(i - 23: i, :), 'omitnan'));
    end
    exposure = (MA3 + MA6 + MA12 + MA24)./ 4;
    offsetSize = 24;
end
