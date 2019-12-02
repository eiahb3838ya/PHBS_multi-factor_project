% Alpha31 (CLOSE-MEAN(CLOSE,12))/MEAN(CLOSE,12)*100
% first 12 will be unuseable
close = projectData.stock.properties.close;

sumPast = zeros(size(close));
for i = 1:12
    toAdd = [zeros(i, size(close, 2));close(1:end-i,:)];
	sumPast = sumPast + toAdd;
end
meanPast = sumPast/12;
alpha = (close-meanPast)/meanPast*100;