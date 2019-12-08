function [X, offsetSize] = alpha013(alphaPara)
% main function
% (HIGH * LOW)^0.5 - VWAP
% min data size: 1
% alphaPara is a structure
    try
        high = alphaPara.high;
        low = alphaPara.low;
        vwap = alphaPara.vwap;
    catch
        error 'para error';
    end

% clean data module here

% get alpha module here
    [X, offsetSize] = getAlpha(high, low, vwap);
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
