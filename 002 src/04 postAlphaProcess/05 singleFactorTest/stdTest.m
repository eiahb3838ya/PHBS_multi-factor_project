function stationarity = stdTest(m,numBootstrp,threshold)
%H0: std(m)=0
std(m);
mBootstrp= bootstrp(numBootstrp,@std,m);            %Bootstrap sampling
ratio = sum(mBootstrp > threshold)/numBootstrp;
if ratio > 0.95                                     %reject H0
     stationarity = 1;
else stationarity = 0;
end
end
