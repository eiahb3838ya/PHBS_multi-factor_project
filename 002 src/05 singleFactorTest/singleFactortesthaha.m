processedClose = load('cleanedData_stock_20191217.mat');
load('factorExposure_20191228.mat');
industryFactor = load('industryFactor_20191231.mat')
load('styleSTR');
styleFactor = styleSTR.styleFactor;
exposure = orthFactors.orthFactors;
alphaNameList = orthFactors.factorName;
alphaName

haha = singleFactorTest(exposure, processedClose,100,1,1,industryFactor,styleFactor,alphaNameList);

tic
haha.plotIC();
toc

tic
haha.plotAllCumFactorReturn();
toc

haha.saveAllAlphaStatResult();

