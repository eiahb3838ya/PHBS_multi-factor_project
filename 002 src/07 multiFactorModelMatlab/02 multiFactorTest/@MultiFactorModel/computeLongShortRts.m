function longShortRts = computeLongShortRts(obj, longShortPercentage, stockCloseMat)
    % position change interval is the same as the prediction
    % interval

    %total days
    totalDays = size(obj.rtMat, 1);
    totalStocks = size(obj.rtMat, 2);

    %number of stocks of each group
    numStockEachGroup = round(totalStocks*longShortPercentage);

    %store 2 things, valid index and stock returns separately
    longShortRts = nan*zeros(totalDays,1);
    counts = (totalDays - obj.icTestForwardDays) - (obj.startIndx + obj.predictionDays) + 1 + obj.smoothingDays;

    if counts <= 0
        error("no enough days for back test.");
    end

    % init a new variable to store.
    allValidIndx = cell(1, totalDays);
    allDayExpectRts = cell(1, totalDays);

    % init a wait bar
    h=waitbar(0,'step 1 of 2,computing factor return:');

    % calculate every day return
    for dayIndx = obj.startIndx + obj.predictionDays:totalDays - obj.predictionDays
        % get one day expected factor returns
        [oneDayExpectRts, oneDayValidIndx] = MultiFactorModel.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, -1, obj.maskShift);
        allDayExpectRts{dayIndx} = oneDayExpectRts;
        allValidIndx{dayIndx} = oneDayValidIndx;

        % wait bar information
        str=['factor return, process day: ',num2str(dayIndx),'/',num2str(totalDays-obj.predictionDays)];
        waitbar(dayIndx/(totalDays - obj.predictionDays),h,str);
    end

    %close wait bar
    close(h);

    % init another wait bar
    h2=waitbar(0,'step 2 of 2,long short return:');

    % start long-short
    for getRtDayIndx = obj.startIndx + obj.predictionDays*2:totalDays - obj.predictionDays
        decideTradeDay = getRtDayIndx - obj.predictionDays;
        % on every decide trade day
        % merge decide day expected return and valid index
        toSort = [allDayExpectRts{decideTradeDay}(allValidIndx{decideTradeDay}),allValidIndx{decideTradeDay}(:)];
        sorted = sortrows(toSort, 1); % ascending sort according to column 1

        longPositionIndx = sorted(1:numStockEachGroup,2);
        longPositionCloseDecideDay = stockCloseMat(decideTradeDay, longPositionIndx);

        shortPositionIndx = sorted(end - numStockEachGroup + 1: end,2);
        shortPositionCloseDecideDay = stockCloseMat(decideTradeDay, shortPositionIndx);

        % find those stocks on get return day
        longPositionCloseGetRtDay = stockCloseMat(getRtDayIndx, longPositionIndx).* obj.stockScreen(getRtDayIndx, longPositionIndx);
        shortPositionCloseGetRtDay = stockCloseMat(getRtDayIndx, shortPositionIndx).* obj.stockScreen(getRtDayIndx, shortPositionIndx);

        longShortRts(getRtDayIndx) = mean(longPositionCloseGetRtDay./longPositionCloseDecideDay - 1,'omitnan')...
            - mean(shortPositionCloseGetRtDay./shortPositionCloseDecideDay - 1, 'omitnan');

        % wait bar information
        str=['long short return, decide day: ',num2str(decideTradeDay),'/',num2str(totalDays-obj.predictionDays)];
        waitbar(decideTradeDay/(totalDays-obj.predictionDays),h2,str);
    end

    close(h2); %close waitbar
end

