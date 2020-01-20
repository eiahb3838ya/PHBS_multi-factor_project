load('NonOrth_orthFactor_20200111.mat')
load('stockScreen_20200111.mat')
load('projectData.mat')
load('returnMatrix.mat')

sector = projectData.stock.sectorClassification.levelOne;
factorExposure = orthFactorCube(2166, :, :);
groupByVector = sector(2166, :);
stockScreenOneDay = stockScreenMatrix(2166,:);

[factorExposureCell, ~] = arrayGroupBy2CellOneDay(factorExposure, ...
    groupByVector, stockScreenOneDay);
stockReturn = rts(2166, :);
[stockReturnCell, ~] = arrayGroupBy2CellOneDay(stockReturn, ...
    groupByVector, stockScreenOneDay);
visualization(factorExposureCell, stockReturnCell)