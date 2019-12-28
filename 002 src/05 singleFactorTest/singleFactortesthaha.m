processedClose = load('cleanedData_stock_20191217.mat');
exposure = load('factorExposure_20191228.mat');

haha = singleFactortest(exposure, processedClose, 200,1,1);
haha.plotIC();
haha.plotAllCumFactorReturn();

