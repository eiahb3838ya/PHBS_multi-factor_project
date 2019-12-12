% STOA
% 
% floatingShares = projectData.stock.properties.floatingShares;
% volume = projectData.stock.properties.volume;

function [X, offsetSize] = stoa(stock)
    [X, offsetSize] = getAlpha(stock.properties.volume, stock.properties.floatingShares);
end

function [exposure, offsetSize] = getAlpha(volume, floatingShares)
    toRollSum = volume./floatingShares;
    rolledPast = sumPast(toRollSum, 21);
    rolledPast = sumPast(rolledPast, 12)./12;
    if size(toRollSum)==size(rolledPast)
        exposure = log(rolledPast);
    end
    offsetSize = 32;
end


