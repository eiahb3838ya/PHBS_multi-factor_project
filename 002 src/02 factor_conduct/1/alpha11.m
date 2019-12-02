% alpha11
%sum(((close - low) - (high - close)) ./(high - low).*volume, 6)
close = projectData.stock.properties.close;
low = projectData.stock.properties.low;
high = projectData.stock.properties.high;
volume = projectData.stock.properties.volume;
toCumsum = ((close - low) - (high - close)) ./(high - low).*volume ;
originSize = size(toCumsum)
alpha = zeros(originSize)
for i = 1:6
    toAdd = [zeros(i, size(toCumsum, 2));toCumsum(1:end-i,:)];
	alpha11 = alpha11 + toAdd;
end