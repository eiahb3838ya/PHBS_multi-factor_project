MFT = MultiFactorTest(stockRtMat, interceptCube, factorExposureCube, 720, 1, 30, 0, 1);
modelICSeries = MFT.computeICTimeSeries(1);