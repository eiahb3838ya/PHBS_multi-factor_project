function IC = ICValue(alpha,day,rollingWindow,d,alphaPara)

try
        close = alphaPara.close;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
end
    
getAlpha = alpha;

[m, n] = size(alphaPara.close);
delayclose = [zeros(1, n);alphaPara.close(1: m - 1,:)];
rts = close./(delayclose + eps) - 1;
%rts (find(isnan(rts)==1)) = 0; % rank 

for i = day - rollingWindow : day - d
corrMatrix = corrcoef(getAlpha(i-(day - rollingWindow) +1,:),rts(i-(day - rollingWindow) +1 +d,:));
IC(i-(day - rollingWindow) +1) = corrMatrix(1,2);
end
end