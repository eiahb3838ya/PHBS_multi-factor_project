%Alpha71 (CLOSE-MEAN(CLOSE,24))/MEAN(CLOSE,24)*100

close = projectData.stock.properties.close;

sumPast = zeros(size(close));
for i = 1:24
    toAdd = [zeros(i, size(close, 2));close(1:end-i,:)];
	sumPast = sumPast + toAdd;
end
meanPast = sumPast/24;
alpha = (close-meanPast)/meanPast*100;