% Alpha31 (CLOSE-MEAN(CLOSE,12))/MEAN(CLOSE,12)*100
% first 12 will be unuseable
% close = projectData.stock.properties.close;


function [X, offsetSize] = alpha31(stock)
    [X, offsetSize] = getAlpha(stock.properties.close);
end

function [exposure, offsetSize] = getAlpha(close)
    sumPast = zeros(size(close));
    for i = 0:11
        toAdd = [zeros(i, size(close, 2));close(1:end-i,:)];
        sumPast = sumPast + toAdd;
    end
    meanPast = sumPast/12;
    exposure = (close-meanPast)/meanPast*100;
    offsetSize = 11;
    return
end

