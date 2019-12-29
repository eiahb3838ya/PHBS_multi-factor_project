processedClose = load('cleanedData_stock_20191217.mat');
load('factorExposure_20191228.mat');

haha = singleFactorTest(exposure, processedClose, 200,1,1);
haha.plotIC();
haha.plotAllCumFactorReturn();
haha.saveAllAlphaStatResult();

