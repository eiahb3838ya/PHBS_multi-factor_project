function [X, offsetSize] = alpha003(alphaPara)
% main function
% SUM((CLOSE = DELAY(CLOSE, 1) ? 0: CLOSE - (CLOSE > DELAY(CLOSE, 1) ?
% MIN(LOW, DELAY(CLOSE, 1)): MAX(HIGH, DELAY(CLOSE, 1)))), 6)
% min data size: 7
% alphaPara is a structure
    try
        high = alphaPara.high;
        low = alphaPara.low;
        close = alphaPara.close;
    catch
        error 'para error';
    end        

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(high, low, close);
    return
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, low, close)
% function compute alpha
    [m, n] = size(close);
    delay = [zeros(1, n);close(1: m - 1,:)];
    
    matrix1 = close;
    matrix1(close == delay) = 0;
    matrix2 = close;
    minMatrix = min(low, delay);
    maxMatrix = max(high, delay);
    matrix2(close > delay) = minMatrix(close > delay);
    matrix2(close <= delay) = maxMatrix(close <= delay);
    matrix = matrix1 - matrix2;
    
    exposure = sumPast(matrix, 6);
    offsetSize = 6;
end

function [exposure, offsetSize] = getAlphaUpdate(high, low, close)
    [m, ~] = size(high);
    offsetSize = 7;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    delay = close(m - 6 : m - 1,:);
    closeTable = close(m - 5: m, :);
    highTable = high(m - 5: m, :);
    lowTable = low(m - 5: m, :);
    matrix1 = close(m - 5: m, :);
    matrix1(closeTable == delay) = 0;
    matrix2 = close(m - 5: m, :);
    minMatrix = min(lowTable, delay);
    maxMatrix = max(highTable, delay);
    matrix2(closeTable > delay) = minMatrix(closeTable > delay);
    matrix2(closeTable <= delay) = maxMatrix(closeTable <= delay);
    matrix = matrix1 - matrix2;
    exposure = sum(matrix);
end
