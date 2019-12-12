function IC = rankICValue(alpha,day,rollingWindow,d,alphaPara)
try
        close = alphaPara.close;
       
    catch
        error 'para error';
end
    
getAlpha = alpha;
[~, Xidx] = sort(getAlpha,2);
[~,Xidx2] = sort(Xidx,2);
getAlha = Xidx2;

[m, n] = size(alphaPara.close);
delayclose = [zeros(1, n);alphaPara.close(1: m - 1,:)];
rts = close./(delayclose + eps) - 1;
[~, Xidxx] = sort(rts,2);
[~,Xidxx2] = sort(Xidxx,2);
rts = Xidxx2;

for i = day - rollingWindow : day - d
corrMatrix = corrcoef(getAlpha(i-(day - rollingWindow) +1,:),rts(i-(day - rollingWindow) +1 +d,:));
IC(i-(day - rollingWindow) +1) = corrMatrix(1,2);
end
end