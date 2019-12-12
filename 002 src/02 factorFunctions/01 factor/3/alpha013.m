function [X, offsetSize] = alpha013(alphaPara)
% main function
% (HIGH * LOW)^0.5 - VWAP
% min data size: 1
% alphaPara is a structure
    try
        high = alphaPara.high;
        low = alphaPara.low;
        vwap = alphaPara.vwap;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getAlpha(high, low, vwap);
        return
    else
        [X, offsetSize] = getAlphaUpdate(high, low, vwap);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getAlpha(high, low, vwap)
% function compute alpha
    exposure = (high .* low)^0.5 - vwap;
    offsetSize = 1;
end

function [exposure, offsetSize] = getAlphaUpdate(high, low, vwap)
    offsetSize = 1;
    exposure = (high .* low)^0.5 - vwap;
end
