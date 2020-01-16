[outputCell, elementIndicator] = arrayGroupBy2CellOneDay(returnOneDay, sectorIndicatorOneDay, stockScreenOneDay);

% where returnOneDay is 1 by stocks, can also be factorExposure, which is 1 by stocks by Alphas.
% sectorIndicatorOneDay is from projectData.stock.sectorClassification.levelOne
% stockScreenOneDay is from stockScreenMatrix
