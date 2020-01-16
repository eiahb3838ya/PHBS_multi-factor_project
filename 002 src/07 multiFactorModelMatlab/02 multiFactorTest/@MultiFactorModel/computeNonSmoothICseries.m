function timeSeriesIC = computeNonSmoothICseries(obj)
%COMPUTENONSMOOTHICSERIES compute IC series of a model            
    %get total days
    totalDays = size(obj.rtMat,1);

    %get IC series
    icArray = nan*ones(totalDays,1);

    % init a waiting bar
    h=waitbar(0,'please wait');
    fastCube = obj.combinedCube(:,:,obj.alphaStartIndex:end);
    for dayIndx = obj.startIndx+obj.predictionDays : totalDays-obj.icTestForwardDays
        %run IC mode
        % stockRtMat, mixCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC
        [icOneDay,~] = MultiFactorModel.computeOneDayICFast(obj.rtMat, obj.combinedCube, fastCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, obj.isRankIC, obj.maskShift);
        icArray(dayIndx) = icOneDay;

        % wait bar information
        str=['process day: ',num2str(dayIndx),'/',num2str(totalDays-obj.icTestForwardDays)];
        waitbar(dayIndx/totalDays,h,str);
    end
    
    close(h);%close waitbar
    
    timeSeriesIC = icArray;

end

