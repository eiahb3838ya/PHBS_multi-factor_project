function [X, offsetSize] = alpha053(alphaPara)
% main function
% COUNT(CLOSE > DELAY(CLOSE, 1), 12) / 12 * 100
% min data size: 13
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
    compare = close > delay;
    exposure = sumPast(compare, 12) ./ 12 .* 100;
    offsetSize = 12;
end

function [exposure, offsetSize] = getAlphaUpdate(close)
    offsetSize = 13;
    [m, ~] = size(close);
    if m < offsetSize
        error 'Lack data. At least data of 7 days.';
    end
    delay = close(m - 12 : m - 1,:);
    closeTable = close(m - 11: m, :);
    compare = closeTable > delay;
    exposure = sum(compare) ./ 12 .* 100;
end
