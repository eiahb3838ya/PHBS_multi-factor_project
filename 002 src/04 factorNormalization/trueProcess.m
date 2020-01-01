load('factorExposure_20191231.mat')
factorCube = factorExposure.factorExposure;

load('industryFactor_20191231.mat')
industryFactorCube = industryFactor;
industryFactorCube(:, :, 1) = [];

load('styleFactors_20191231.mat')
styleFactorCube = styleSTR.styleFactors;
styleFactorCube = cat(3, styleFactorCube(:, :, 1), styleFactorCube(:, :, 3: 9));

normProcess = FactorNormalization(factorCube);
normProcess.calculateNorm();
normProcess.calculateOrth(styleFactorCube, industryFactorCube);

normedFactorCube = normProcess.processedFactor;
orthFactorCube = normProcess.orthedFactor;