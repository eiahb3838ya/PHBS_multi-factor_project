%Alpha71 (CLOSE-MEAN(CLOSE,24))/MEAN(CLOSE,24)*100

% close = projectData.stock.properties.close;

function [X, offsetSize] = alpha71(stock)
    [X, offsetSize] = getAlpha(stock.properties.close);
end

function [exposure, offsetSize] = getAlpha(close)
    sumPast = zeros(size(close));
    for i = 0:24-1
        toAdd = [zeros(i, size(close, 2));close(1:end-i,:)];
        sumPast = sumPast + toAdd;
    end
    meanPast = sumPast/24;
    exposure = (close-meanPast)/meanPast*100;
    offsetSize = 23;
    return
end

