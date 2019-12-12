function [X, offsetSize] = alpha103(alphaPara)
% main function
% ((20 - LOWDAY(LOW, 20)) / 20) * 100
% min data size: 20
% alphaPara is a structure
    try
        low = alphaPara.low;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end 

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getAlpha(low);
        return
    else
        [X, offsetSize] = getAlphaUpdate(low);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(low)
% function compute alpha
    exposure = (20 - lowday(low, 20))./ 20.* 100;
    offsetSize = 20;
end

function [exposure, offsetSize] = getAlphaUpdate(low)
    [m, ~] = size(low);
    offsetSize = 20;
    if m < offsetSize
        error 'Lack data. At least data of 20 days.';
    end
    lowTable = low(m - 19: m, :);
    exposure = (20 - lowday(lowTable, 20))./ 20.* 100;
    exposure = exposure(20, :);
end