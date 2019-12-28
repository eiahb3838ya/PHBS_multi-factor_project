processedClose = load('cleanedData_stock_20191217.mat');
load('factorToTest20191217.mat');
processedAlpha(:,:,1) = fE.alpha10;
processedAlpha(:,:,2) = fE.alpha100;
processedAlpha(:,:,3) = fE.alpha110;
processedAlpha(:,:,4) = fE.alpha150;
processedAlpha(:,:,5) = fE.alpha160;
processedAlpha(:,:,6) = fE.alpha20;
processedAlpha(:,:,7) = fE.alpha70;
processedAlpha(:,:,8) = fE.alpha80;

haha = singleFactortest(processedAlpha, processedClose, 200,1,1)
haha.plotIC()
haha.plotAllCumFactorReturn()

