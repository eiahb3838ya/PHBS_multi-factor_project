% Alpha171 ((-1 * ((LOW - CLOSE) * (OPEN^5))) / ((CLOSE - HIGH) * (CLOSE^5))

close = projectData.stock.properties.close;
low = projectData.stock.properties.low;
high = projectData.stock.properties.high;
open = projectData.stock.properties.open;

alpha = (-1 * ((low - close) .* (open.^5))) ./ ((close - high) .* (close.^5))