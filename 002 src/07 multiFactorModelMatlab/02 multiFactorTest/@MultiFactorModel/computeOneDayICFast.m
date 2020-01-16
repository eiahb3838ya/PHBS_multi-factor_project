function [oneDayModelIC, validIndx] = computeOneDayICFast(stockRtMat, cube, fastCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC, maskShift)
% COMPUTEONEDAYIC computeOneDayICFast(stockRtMat, cube, fastCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC)
    if nargin == 6
        predictionDays = 1;
        maskShift = -1*predictionDays;
        icTestForwardDays = 1;
        isRankIC = 1;
    end

    % factor rts, length is #features
    [factorRts, ~] = MultiFactorModel.computeOneDayFtRts(stockRtMat, cube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskShift);

    % get stock return ready to test IC
    % get stock exposure of size stocks by features
    icDayForwardStockRt = stockRtMat(currentDayIndx + icTestForwardDays,:); %1 by stocks,R_t+1
    oneDayFactorExposure = MultiFactorModel.cube2Mat(fastCube, currentDayIndx); %features by stocks,fastCube = mixCube(:,:,alphaStartIndx:end)

    % get valid stock 
    stockScreenOneDay = stockScreen(currentDayIndx,:);
    stockScreenValidIndx = find(stockScreenOneDay==1);
    [nanInfValidIndx, ~, ~] = MultiFactorModel.preprocessEntry([icDayForwardStockRt',oneDayFactorExposure']);%pick by stock's num
    validIndx = intersect(nanInfValidIndx, stockScreenValidIndx);

    if isRankIC == -1
        oneDayModelIC = oneDayFactorExposure'*factorRts';
        return;
    end

    rtsContributedByFts = oneDayFactorExposure(:,validIndx)'*factorRts'; %column vector

    icStockRts = icDayForwardStockRt(validIndx);
    icFtRts = rtsContributedByFts;

    if isRankIC == 1
        oneDayModelIC = MultiFactorModel.rankCorr(icStockRts, icFtRts);
    elseif isRankIC == 0
        oneDayModelIC = MultiFactorModel.commonCorr(icStockRts, icFtRts);
    else
        error("isRankIC can only be 0 or 1 or -1");
    end    
end
    

