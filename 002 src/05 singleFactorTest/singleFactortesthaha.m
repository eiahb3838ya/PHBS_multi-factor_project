processedClose = load('closeStock.mat');
processedClose.close = close;
load('factorExposure_20191228.mat');
industryFactor = load('industryFactor_20191231.mat')


%load('styleSTR');
styleFactor = styleSTR.styleFactors;
industryFactor = industryFactor.industryFactor;
exposure = newExposure.exposure;
alphaNameList = newExposure.alphaNameList;

haha = singleFactorTest(orthFactorCube, processedClose,1465,1,0,stockScreenMatrix,industryFactor,styleFactor,alphaNameList);
%xixi = singleFactorTest(exposure, processedClose,900,1,0,industryFactor,styleFactor,alphaNameList);
haha = singleFactorTest(orthFactorCube, processedClose,1465,1,1,stockScreenMatrix,industryFactor,styleFactor,alphaNameList);

%不和style正交化后的结果 计算NormalIC
haha = singleFactorTest(orthFactorCube, processedClose,1465,1,0,stockScreenMatrix,industryFactor,[],alphaNameList);

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
