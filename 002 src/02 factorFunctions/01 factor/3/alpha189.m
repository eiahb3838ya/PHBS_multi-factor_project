function [X, offsetSize] = alpha189(alphaPara)
% main function
% MEAN(ABS(CLOSE - MEAN(CLOSE, 6)), 6)
% min data size: 11
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
        [X, offsetSize] = getAlpha(close);
        return
    else
        [X, offsetSize] = getAlphaUpdate(close);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(close)
% function compute alpha
    [m, n] = size(close);
    meanClose = zeros(m ,n);
    for i =1: 5
        meanClose(i, :) = mean(close(1: i, :));
    end
    for i = 6: m
        meanClose(i, :) = mean(close(i - 5: i, :));
    end
    absClose = abs(close - meanClose);
    exposure = zeros(m, n);
    for i =1: 5
        exposure(i, :) = mean(absClose(1: i, :));
    end
    for i = 6: m
        exposure(i, :) = mean(absClose(i - 5: i, :));
    end
    offsetSize = 11;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
% function compute alpha
    [m, n] = size(close);
    offsetSize = 11;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    closeTable = close(m - offsetSize + 1: m, :);
    meanClose1 = zeros(6, n);
    for i = 1: 6
        meanClose1(i, :) = mean(closeTable(i: i + 5, :));
    end
    closeTable = closeTable(offsetSize - 5: offsetSize, :);
    absClose = abs(closeTable - meanClose1);
    exposure = mean(absClose);
end