% STOA
% 
% floatingShares = projectData.stock.properties.floatingShares;
% volume = projectData.stock.properties.volume;

% function [X, offsetSize] = stoa(stock)
%     [X, offsetSize] = getAlpha(stock.properties.volume, stock.properties.floatingShares);
% end
% 
% function [exposure, offsetSize] = getAlpha(volume, floatingShares)
%     toRollSum = volume./floatingShares;
%     rolledPast = sumPast(toRollSum, 21);
%     rolledPast = sumPast(rolledPast, 12)./12;
%     if size(toRollSum)==size(rolledPast)
%         exposure = log(rolledPast);
%     end
%     offsetSize = 32;
% end

function [X, offsetSize] = STOA(alphaPara)
% alphaPara is a structure

    try
        volume = alphaPara.volume;
        floatingShares  = alphaPara.floatingShares;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getSTOA(volume, floatingShares);
        return
    else
        [X, offsetSize] = getSTOAUpdate(volume, floatingShares);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getSTOA(volume, floatingShares)
% function compute factor exposure of style factor
    toRollSum = volume./floatingShares;
    rolledPast = sumPast(toRollSum, 21);
    rolledPast = sumPast(rolledPast, 12)./12;
    if size(toRollSum)==size(rolledPast)
        exposure = log(rolledPast);
    end
    offsetSize = 32;
end

function [exposure, offsetSize] = getSTOAUpdate(volume, floatingShares)
% function compute factor exposure of style factor
    [X, offsetSize] = getSTOA(volume, floatingShares);
    exposure = X(end,:);
end


