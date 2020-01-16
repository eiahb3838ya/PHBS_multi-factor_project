function signaficance = absMeanTest(m,numBootstrp)
%H0: mean(|m|)=0
mean(abs(m));
mBootstrp= bootstrp(numBootstrp,@mean,abs(m));      %Bootstrap sampling
ratio = sum(mBootstrp > 0)/numBootstrp;
if ratio > 0.95                                     %reject H0
     signaficance = 1;
else signaficance = 0;
end
end