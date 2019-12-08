function [X, offsetSize] = alpha133(alphaPara)
% main function
% ((20 - HIGHDAY(HIGH, 20)) / 20) * 100 - ((20 - LOWDAY(LOW, 20)) / 20) * 100
% min data size: 20
% alphaPara is a structure
    try
        high = alphaPara.high;
        low = alphaPara.low;
    catch
        error 'para error';
    end

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(high, low);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, low)
% function compute alpha
    exposure = (20 - highday(high, 20))./ 20.* 100 - (20 - lowday(low, 20))./ 20.* 100;
    offsetSize = 20;
end

function [exposure, offsetSize] = getAlphaUpdate(high, low)
    [m, ~] = size(high);
    offsetSize = 20;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    highTable = high(m - 19: m, :);
    lowTable = low(m - 19: m, :);
    exposure = (20 - highday(highTable, 20))./ 20.* 100 - (20 - lowday(lowTable, 20))./ 20.* 100;
end
