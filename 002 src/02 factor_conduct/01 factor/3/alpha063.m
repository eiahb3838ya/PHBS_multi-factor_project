function [X, offsetSize] = alpha063(alphaPara)
% main function
% SMA(MAX(CLOSE - DELAY(CLOSE, 1), 0), 6, 1) / SMA(ABS(CLOSE - DELAY(CLOSE,
% 1)), 6, 1) * 100
% min data size: 7
% input all the data, not just the latest 7 days' data
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
    delay = [zeros(1, n);close(1: m - 1,:)];
    maxMatrix = max(close - delay, zeros(m, n));
    absMatrix = abs(close - delay);
    
    exposure = sma(maxMatrix, 6, 1)./ sma(absMatrix, 6, 1) * 100;
    offsetSize = 6;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
% function compute alpha
    offsetSize = 7;
    [m, n] = size(close);
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    delay = [zeros(1, n);close(1: m - 1,:)];
    maxMatrix = max(close - delay, zeros(m, n));
    absMatrix = abs(close - delay);
    exposure = sma(maxMatrix, 6, 1)./ sma(absMatrix, 6, 1) * 100;
end
