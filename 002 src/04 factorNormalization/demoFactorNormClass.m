normProcess = factorNormalization(factorCube);
normProcess.calculateNorm();
normProcess.calculateOrth(styleFactorCube, industryFactorCube);

normedFactorCube = normProcess.processedFactor;
orthFactorCube = normProcess.orthedFactor;