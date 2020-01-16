function timeSeriesIC = computeSmoothICTimeSeries(obj, smoothFunc, smoothParam)
%COMPUTESMOOTHICTIMESERIES smooth ic time series for a model.
% when preparing smooth function, it should be a function working on a
% matrix of size N by T, and T-th index represents the earliest day.And
% should return a vector of size N by 1.
% smooth function should be like ansVector = smoothFunc(X, smoothParam)
    %indicate smoothing period
    disp(['compute IC, smoothing periods: ',num2str(obj.smoothingDays)]);
    disp(['compute IC, is rank IC: ', num2str(obj.isRankIC)]);
    
    if nargin == 0
        disp('use default method, moving average to smooth');
        smoothFunc = 'defaultSmoothingMethod';
        smoothParam.T = obj.smoothingDays;
    end

    %total days
    totalDays = size(obj.rtMat, 1);
    totalStocks = size(obj.rtMat, 2);

    %store 2 things, valid index and stock returns separately
    timeSeriesIC = nan*zeros(totalDays,1);
    counts = (totalDays - obj.icTestForwardDays) - (obj.startIndx + obj.smoothingDays + obj.predictionDays - 1) + 1;
    if counts <= 0
        error("no enough days for back test.");
    end

    % init a new variable to store.
    allValidIndx = cell(1, totalDays);
    allDayExpectRts = cell(1, totalDays);

    % init a wait bar
    h=waitbar(0,'step 1 of 2,computing factor return:');

    % calculate every day return
    for dayIndx = obj.startIndx + obj.predictionDays:totalDays - obj.icTestForwardDays
        % get one day expected factor returns
        [oneDayExpectRts, oneDayValidIndx] = MultiFactorModel.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, -1, obj.maskShift);
        allDayExpectRts{dayIndx} = oneDayExpectRts;
        allValidIndx{dayIndx} = oneDayValidIndx;

        % wait bar information
        str=['factor return, process day: ',num2str(dayIndx),'/',num2str(totalDays)];
        waitbar(dayIndx/totalDays,h,str);
    end

    %close wait bar
    close(h);

    % init another wait bar
    h2=waitbar(0,'step 2 of 2,smoothing:');

    % smoothing using every T days, and do correlation with T+d
    % stock returns
    for currentDayIndx = obj.startIndx + obj.smoothingDays + obj.predictionDays - 1:totalDays - obj.icTestForwardDays
        smoothStartDay = currentDayIndx - obj.smoothingDays + 1;
        periodValidIndx = 1:totalStocks;
        periodValidExpectedRts = nan*zeros(totalStocks,obj.smoothingDays);
        for t = smoothStartDay:currentDayIndx
            periodValidIndx = intersect(periodValidIndx, allValidIndx{t});
            periodValidExpectedRts(:,t-smoothStartDay+1) = allDayExpectRts{t};
        end

        % get a matrix of size stocks by T days
        periodValidExpectedRts = periodValidExpectedRts(periodValidIndx,:);

        if obj.isRankIC == 1
%             timeSeriesIC(currentDayIndx) = MultiFactorModel.commonCorr(sum(periodValidExpectedRts,2), obj.rtMat(currentDayIndx+obj.icTestForwardDays,periodValidIndx));
            timeSeriesIC(currentDayIndx) = MultiFactorModel.commonCorr(feval(smoothFunc,periodValidExpectedRts,smoothParam), obj.rtMat(currentDayIndx+obj.icTestForwardDays,periodValidIndx));
        elseif obj.isRankIC == 0
%             timeSeriesIC(currentDayIndx) = MultiFactorModel.rankCorr(sum(periodValidExpectedRts,2), obj.rtMat(currentDayIndx+obj.icTestForwardDays,periodValidIndx));
            timeSeriesIC(currentDayIndx) = MultiFactorModel.rankCorr(feval(smoothFunc,periodValidExpectedRts,smoothParam), obj.rtMat(currentDayIndx+obj.icTestForwardDays,periodValidIndx));
        else
            error("isRankIC can only be 0 or 1.");
        end

        % wait bar information
        str=['smoothing, process day: ',num2str(dayIndx),'/',num2str(totalDays)];
        waitbar(dayIndx/totalDays,h2,str);
    end

    %close wait bar
    close(h2);
end

function ansVector = defaultSmoothingMethod(X, param)
    T = param.T;
    ansVector = 1/T*sum(X,2);
end
