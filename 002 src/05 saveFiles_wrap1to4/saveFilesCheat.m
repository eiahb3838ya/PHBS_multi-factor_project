%ROOT = '/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/01 dataStorage';
function saveFiles(projectData, ROOT)
%set today str for naming
todayStr = datestr(now, 'yyyymmdd');

% Step 1:create clean data

fileDir = strcat(ROOT, '/01 cleanData/02 cleanDataStruct/');
gotoFolder(fileDir);
CDM = load('cleanedData_sliced_20200112.mat');
% CDM.runHistory(); 
% CDM.addInconsistentTableToResult(projectData.index.totalReturn(:,7),'indexTotalReturn');
% 
% % save cleanData
% fileDir = strcat(ROOT, '/01 cleanData/02 cleanDataStruct/');
% gotoFolder(fileDir);
% CDM.saveResult('stock');
disp('cleanData......done')

% create stockScreenMatrix
fileDir = strcat(ROOT, '/01 cleanData/01 stockScreen/');
gotoFolder(fileDir);

% load 
fileDir = strcat(ROOT, '/01 cleanData/01 stockScreen/');
gotoFolder(fileDir);
stockScreenMatrix = load('stockScreen_20200112.mat');
disp('stockScreen......done')
% save stockScreenMatrix
% fileName = strcat('stockScreen_',todayStr);
% fileDir = strcat(ROOT, '/01 cleanData/01 stockScreen/');
% gotoFolder(fileDir);
% matobj = matfile(fileName, 'Writable', true);
% matobj.('stockScreenMatrix') = stockScreenMatrix;
% clear matobj

% Step 2: save all alpha factors 
AF = AlphaFactory('haha', 'factorExposureParamStruct.json', CDM.('getResult'));
fileDir = strcat(ROOT, '/03 factorExposure/');
gotoFolder(fileDir);
alphaFilePrefix = 'factorExposure';
alphaFileName = strcat(alphaFilePrefix,'_',todayStr,'.mat');
AF.saveAllAlphaHistory(alphaFilePrefix);

% load alpha factors 
alphaFactorMat = load(alphaFileName);
alphaFactorCube =  alphaFactorMat.('exposure');
disp('alphaFactor......done')
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
disp('industryFactor......done')

%create style factors
alphaFilePrefix = 'styleFactor';
AF = AlphaFactory('haha', 'Copy_of_styleParamStruct.json', CDM.('getResult'));
fileDir = strcat(ROOT, '/02 styleFactor/02 styleFactor/');
gotoFolder(fileDir);

%save style factors
AF.saveAllAlphaHistory(alphaFilePrefix);
alphaFileName = strcat(alphaFilePrefix,'_',todayStr,'.mat');
styleFactorMat = load(alphaFileName);
styleFactorCube = styleFactorMat.('exposure');
disp('styleFactor......done')
% Step 4: Norm and Orth the factor

fileDir = strcat(ROOT, '/04 factorNormalization/');
gotoFolder(fileDir);
normProcess = FactorNormalization(alphaFactorCube);
normProcess.calculateNorm();
normProcess.calculateOrth([], industryFactorCube(1600:end, :, :));

% save orthedFactorCube
orthFactorCube = normProcess.orthedFactor;
fileName = strcat('orthFactor_',todayStr);

matobj = matfile(fileName, 'Writable', true);
matobj.('orthFactorCube') = orthFactorCube;
clear matobj

end