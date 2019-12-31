% STOM
% 
% floatingShares = projectData.stock.properties.floatingShares;
% volume = projectData.stock.properties.volume;

% function [X, offsetSize] = stom(stock)
%     [X, offsetSize] = getAlpha(stock.properties.volume, stock.properties.floatingShares);
% end
% 
% function [exposure, offsetSize] = getAlpha(volume, floatingShares)
%     toRollSum = volume./floatingShares;
%     rolledPast = sumPast(toRollSum, 21);
%     if size(toRollSum)==size(rolledPast)
%         exposure = log(rolledPast);
%     end
%     offsetSize = 21;
% end


function [X, offsetSize] = STOM(alphaPara)
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
        [X, offsetSize] = getSTOM(volume, floatingShares);
        return
    else
        [X, offsetSize] = getSTOMUpdate(volume, floatingShares);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getSTOM(volume, floatingShares)
% function compute factor exposure of style factor
    toRollSum = volume./floatingShares;
    rolledPast = sumPast(toRollSum, 21);
    if size(toRollSum)==size(rolledPast)
        exposure = log(rolledPast);
    end
    offsetSize = 21;
end

function [exposure, offsetSize] = getSTOMUpdate(volume, floatingShares)
% function compute factor exposure of style factor
    [X, offsetSize] = getSTOM(volume, floatingShares);
    exposure = X(end,:);
end


