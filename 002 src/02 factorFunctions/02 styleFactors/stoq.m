% STOQ
% 
% floatingShares = projectData.stock.properties.floatingShares;
% volume = projectData.stock.properties.volume;

function [X, offsetSize] = stoq(stock)
    [X, offsetSize] = getAlpha(stock.properties.volume, stock.properties.floatingShares);
end

function [exposure, offsetSize] = getAlpha(volume, floatingShares)
    toRollSum = volume./floatingShares;
    rolledPast = sumPast(toRollSum, 21);
    rolledPast = sumPast(rolledPast, 3)./3;
    if size(toRollSum)==size(rolledPast)
        exposure = log(rolledPast);
    end
    offsetSize = 24;
end


