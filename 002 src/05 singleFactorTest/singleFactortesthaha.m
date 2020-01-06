processedClose = load('closeStock.mat');
processedClose.close = close;
load('factorExposure_20191228.mat');
industryFactor = load('industryFactor_20191231.mat')
load('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/01 dataStorage/02 styleFactor/styleFactors_20191231.mat');

%load('styleSTR');
styleFactor = styleSTR.styleFactors;
industryFactor = industryFactor.industryFactor;
exposure = orthFactors.orthFactors;
alphaNameList = orthFactors.factorName;

haha = singleFactorTest(exposure, processedClose,200,1,1,industryFactor,styleFactor,alphaNameList);

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
