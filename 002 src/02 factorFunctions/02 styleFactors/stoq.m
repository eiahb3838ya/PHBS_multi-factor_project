% STOQ
% 
% floatingShares = projectData.stock.properties.floatingShares;
% volume = projectData.stock.properties.volume;

% function [X, offsetSize] = STOQ(stock)
%     [X, offsetSize] = getAlpha(stock.properties.volume, stock.properties.floatingShares);
% end
% 
% function [exposure, offsetSize] = getAlpha(volume, floatingShares)
%     toRollSum = volume./floatingShares;
%     rolledPast = sumPast(toRollSum, 21);
%     rolledPast = sumPast(rolledPast, 3)./3;
%     if size(toRollSum)==size(rolledPast)
%         exposure = log(rolledPast);
%     end
%     offsetSize = 24;
% end


function [X, offsetSize] = STOQ(alphaPara)
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
        [X, offsetSize] = getSTOQ(volume, floatingShares);
        return
    else
        [X, offsetSize] = getSTOQUpdate(volume, floatingShares);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getSTOQ(volume, floatingShares)
% function compute factor exposure of style factor
    toRollSum = volume./floatingShares;
    rolledPast = sumPast(toRollSum, 21);
    rolledPast = sumPast(rolledPast, 3)./3;
    if size(toRollSum)==size(rolledPast)
        exposure = log(rolledPast);
    end
    offsetSize = 24;
end

function [exposure, offsetSize] = getSTOQUpdate(volume, floatingShares)
% function compute factor exposure of style factor
    [X, offsetSize] = getSTOQ(volume, floatingShares);
    exposure = X(end,:);
end


