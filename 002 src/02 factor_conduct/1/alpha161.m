% Alpha161 MEAN(MAX(MAX((HIGH-LOW),ABS(DELAY(CLOSE,1)-HIGH)),ABS(DELAY(CLOSE,1)-LOW)),12)
% first 12
close = projectData.stock.properties.close;
low = projectData.stock.properties.low;
high = projectData.stock.properties.high;
open = projectData.stock.properties.open;

closeDelay = [zeros(1, size(close, 2));close(1:end-1,:)];
A = max(max(high-low,abs(closeDelay-high)),abs(closeDelay-low));

sumPast = zeros(size(A));
for i = 1:12
    toAdd = [zeros(i, size(A, 2));A(1:end-i,:)];
	sumPast = sumPast + toAdd;
end
alpha = sumPast/12;
