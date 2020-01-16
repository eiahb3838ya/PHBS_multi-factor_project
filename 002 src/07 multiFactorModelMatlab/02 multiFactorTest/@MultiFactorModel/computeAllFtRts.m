function factorRtMat = computeAllFtRts(obj)
%COMPUTEALLFTRTS compute all days factor returns            
    % get total days and total features a day
    totalDays = size(obj.rtMat,1);
    totalFeatures = size(obj.combinedCube,3) - obj.alphaStartIndex + 1;

    % it's like, the first pDays rows do not exist
    factorRtMat = nan*zeros(totalDays, totalFeatures);

    % init a waiting bar
    h=waitbar(0,'please wait');

    for dayIndx = obj.startIndx+obj.predictionDays : totalDays
        % run regression
        [oneDayFtRts,~] = MultiFactorModel.computeOneDayFtRts(obj.rtMat, obj.combinedCube, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.stockScreen, obj.maskShift);
        factorRtMat(dayIndx,:) = oneDayFtRts;

        % wait bar information
        str=['process day: ',num2str(dayIndx),'/',num2str(totalDays)];
        waitbar(dayIndx/totalDays,h,str);
    end

    close(h); %close waitbar

    end
