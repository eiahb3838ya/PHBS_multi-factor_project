function [X, offsetSize] = ETOP(alphaPara)
% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% earnings_ttm / mkt_freeshares
% min data size: 1
% alphaPara is a structure
    try
        PE_TTM = alphaPara.PETTM;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getETOP(PE_TTM);
        return
    else
        [X, offsetSize] = getETOPUpdate(PE_TTM);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getETOP(PE_TTM)
% function compute factor exposure of style factor
    exposure = 1 ./ PE_TTM;
    offsetSize = 1;
end

function [exposure, offsetSize] = getETOPUpdate(PE_TTM)
    offsetSize = 1;
    [m, ~] = size(PE_TTM);
    exposure = 1 ./ PE_TTM(m,:);
end