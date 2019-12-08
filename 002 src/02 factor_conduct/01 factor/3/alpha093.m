function [X, offsetSize] = alpha093(alphaPara)
% main function
% SUM((OPEN >= DELAY(OPEN, 1) ? 0: MAX((OPEN - LOW), (OPEN - DELAY(OPEN,
% 1)))),20)
% min data size: 21
% alphaPara is a structure
    try
        open = alphaPara.open;
        low = alphaPara.low;
    catch
        error 'para error';
    end

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(open, low);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(open, low)
% function compute alpha
    [m, n] = size(open);
    delay = [zeros(1, n);open(1: m - 1,:)];
    maxMatrix = max((open - low), (open - delay));
    matrix = zeros(m, n);
    matrix(open < delay) = maxMatrix(open < delay);
    
    exposure = sumPast(matrix, 20);
    offsetSize = 20;
end

function [exposure, offsetSize] = getAlphaUpdate(open, low)
    [m, ~] = size(open);
    offsetSize = 21;
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    delay = open(m - 20 : m - 1,:);
    openTable = open(m - 19: m, :);
    lowTable = low(m - 19: m, :);
    maxMatrix = max((openTable - lowTable), (openTable - delay));
    matrix = zeros(20, n);
    matrix(openTable < delay) = maxMatrix(openTable < delay);    
    exposure = sum(matrix);
end