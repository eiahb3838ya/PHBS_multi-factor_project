%ROOT = '/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/01 dataStorage';
function saveFiles(projectData, ROOT)
%set today str for naming
todayStr = datestr(now, 'yyyymmdd');

% Step 1:create clean data
CDM = CleanDataModule(projectData);
CDM.runHistory(); 
CDM.addInconsistentTableToResult(projectData.index.totalReturn(:,7),'indexTotalReturn');

% save cleanData
fileDir = strcat(ROOT, '/01 cleanData/02 cleanDataStruct/');
gotoFolder(fileDir);
CDM.saveResult('stock');

% create stockScreenMatrix
stockScreenMatrix = CDM.getStockScreenMatrix();

% save stockScreenMatrix
fileName = strcat('stockScreen_',todayStr);
fileDir = strcat(ROOT, '/01 cleanData/01 stockScreen/');
gotoFolder(fileDir);
matobj = matfile(fileName, 'Writable', true);
matobj.('stockScreenMatrix') = stockScreenMatrix;
clear matobj

% Step 2: get alpha factors 
AF = AlphaFactory('haha', 'factorExposureParamStruct.json', CDM.getResult());

fileDir = strcat(ROOT, '/03 factorExposure/');
gotoFolder(fileDir);

alphaFilePrefix = 'factorExposure';
alphaFileName = strcat(alphaFilePrefix,'_',todayStr,'.mat');

% should be alphaFactorCube Later and assign to saveAllAlphaHistory
AF.saveAllAlphaHistory(alphaFilePrefix);

% load alpha factors 
alphaFactorMat = load(alphaFileName);
alphaFactorCube =  alphaFactorMat.('exposure');
% Step 3: get industry factors and style factors
% create industry factors 

industryFactorCube = mat2CubeOneHotEncoding(projectData.stock.sectorClassification.levelOne);

% save industry factors
fileDir = strcat(ROOT, '/02 styleFactor/01 industryFactor/');
gotoFolder(fileDir);
fileName = strcat('industryFactor_',todayStr);
matobj = matfile(fileName, 'Writable', true);
matobj.('exposure') = industryFactorCube;
clear matobj

%create style factors
alphaFilePrefix = 'styleFactor';
AF = AlphaFactory('haha', 'styleParamStruct.json', CDM.getResult());
fileDir = strcat(ROOT, '/02 styleFactor/02 styleFactor/');
gotoFolder(fileDir);

%save style factors
AF.saveAllAlphaHistory(alphaFilePrefix);
alphaFileName = strcat(alphaFilePrefix,'_',todayStr,'.mat');
styleFactorMat = load(alphaFileName);
styleFactorCube = styleFactorMat.('exposure');

% Step 4: Norm and Orth the factor

normProcess = FactorNormalization(alphaFactorCube);
normProcess.calculateNorm();
normProcess.calculateOrth(styleFactorCube, industryFactorCube);

% save orthedFactorCube
orthFactorCube = normProcess.orthedFactor;
fileName = strcat('orthFactor_',todayStr);
fileDir = strcat(ROOT, '/04 factorNormalization/');
gotoFolder(fileDir);
matobj = matfile(fileName, 'Writable', true);
matobj.('orthFactorCube') = orthFactorCube;
clear matobj

end