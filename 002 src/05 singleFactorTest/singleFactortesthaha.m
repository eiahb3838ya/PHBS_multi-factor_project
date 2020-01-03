processedClose = load('cleanedData_stock_20191217.mat');
load('factorExposure_20191228.mat');
industryFactor = load('industryFactor_20191231.mat')
load('styleSTR');
styleFactor = styleSTR.styleFactor;
exposure = orthFactors.orthFactors;
alphaNameList = orthFactors.factorName;

haha = singleFactorTest(exposure, processedClose,200,1,0,industryFactor,styleFactor,alphaNameList);

tic
haha.plotIC();
toc

tic
haha.plotAllCumFactorReturn();
toc

tic
haha.plotAllcumlongShortReturnTable()
toc

tic
haha.saveAllAlphaStatResult();
toc
