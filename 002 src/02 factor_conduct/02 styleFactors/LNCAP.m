function [X, offsetSize] = LNCAP(alphaPara)
% Returns the log value of the total market capital of single stocks
% log(total market capital)
% min data size: 1
% alphaPara is a structure
    try
        totalMktCap = alphaPara.totalMktCap;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getLNCAP(totalMktCap);
        return
    else
        [X, offsetSize] = getLNCAPUpdate(totalMktCap);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getLNCAP(totalMktCap)
% function compute factor exposure of style factor
    exposure = log(totalMktCap);
    offsetSize = 1;
end

function [exposure, offsetSize] = getLNCAPUpdate(totalMktCap)
% function compute factor exposure of style factor
    offsetSize = 1;
    [m, ~] = size(totalMktCap);
    exposure = log(totalMktCap(m, :));
end