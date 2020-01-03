function getPassAlpha(exposure, alphaName,startTime)
passNumber = alphaEDA(exposure, alphaName,startTime);
[m,n,p] = size(exposure);
for i = m-startTime +1:m
    saveSelectAlpha{i - (m-startTime)} = alphaName(passNumber(i,:));
end
           
dt = datestr(now,'yyyymmdd');
filepath = pwd;
cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/06 multiFactorTest');
savePath = strcat('corrAlphaTest_result_',dt,'.mat');
save(savePath,'saveSelectAlpha');
cd(filepath);
end