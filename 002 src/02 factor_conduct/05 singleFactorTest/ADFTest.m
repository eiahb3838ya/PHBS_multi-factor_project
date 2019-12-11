function stationarity = ADFTest(m)
[H,pValue]=adftest(abs(m));
if pValue < 0.05                   %reject H0, 认为原序列是平稳的
     stationarity =1;
else stationarity =0;
end
