processedClose = load('cleanedData_stock_20191217.mat');
load('factorExposure_20191228.mat');

haha = singleFactorTest(normFactor, processedClose, 50,1,1,industryCube,styleCube,alphaNameList);
haha.plotIC();
haha.plotAllCumFactorReturn();
haha.saveAllAlphaStatResult();

