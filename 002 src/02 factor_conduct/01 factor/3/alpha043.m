function [X, offsetSize] = alpha043(alphaPara)
% main function
% SUM((CLOSE > DELAY(CLOSE, 1) ? VOLUME: (CLOSE < DELAY(CLOSE, 1) ?
% -VOLUME: 0)), 6)
% min data size: 1
% alphaPara is a structure
    try
        close = alphaPara.close;
        volume = alphaPara.volume;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getAlpha(close, volume);
        return
    else
        [X, offsetSize] = getAlphaUpdate(close, volume);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(close, volume)
% function compute alpha
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    matrix = close;
    matrix(close < delay) = -volume(close < delay);
    matrix(close == delay) = 0;
    matrix(close > delay) = volume(close > delay);
    
    exposure = sumPast(matrix, 6);
    offsetSize = 6;
end

function [exposure, offsetSize] = getAlphaUpdate(close, volume)
    offsetSize = 7;
    [m, ~] = size(close);
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    delay = close(m - 6 : m - 1,:);
    closeTable = close(m - 5: m, :);
    volumeTable = volume(m - 5: m, :);
    matrix = closeTable;
    matrix(closeTable < delay) = -volumeTable(closeTable < delay);
    matrix(closeTable == delay) = 0;
    matrix(closeTable > delay) = volumeTable(closeTable > delay);
    exposure = sum(matrix);
end
