function [factorRts, validIndx] = computeOneDayFtRts(rtMat, cube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskShift)
    %COMPUTEONEDAYFTRTS  computeOneDayFtRts(rtMat, cube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskShift)
    % however, this function cannot deal with alpha screen mask, can only deal
    % with stock screen mask, and this one is calculating for a multiple
    % factor model mostly.
    if nargin == 4
        predictionDays = 1;
        stockScreen = ones(size(rtMat));
        maskShift = -1*predictionDays;
    end

    try
        %cube like days by stocks by features
        mat = MultiFactorModel.cube2Mat(cube, currentDayIndx - predictionDays); %mat: features by stocks
        dayRts = rtMat(currentDayIndx,:); %dayRts: 1 by stocks

        % preprocess data
        preprocessData = [dayRts',mat']; % [stock by 1, stock by features]

        % stock screen mask
        stockScreenOneDay = stockScreen(currentDayIndx+maskShift,:);
        stockScreenValidIndx = find(stockScreenOneDay==1);

        % nan, inf mask
        [nanInfValidIndx, ~, ~] = MultiFactorModel.preprocessEntry(preprocessData);%pick by stock's num

        % combine nan,inf mask and stock screen mask
        validIndx = intersect(nanInfValidIndx, stockScreenValidIndx);

        % get x, y for regression
        % remove columns that are all zeros
        allZeroColumn = find(sum(abs(preprocessData(validIndx,2:end)))==0);% is any feature is empty
        if ~isempty(allZeroColumn)
            notAllZeroColumn = setdiff(1:size(preprocessData,2)-1, allZeroColumn);
            shiftDummy = 1;
        else
            notAllZeroColumn = 2:size(preprocessData,2);
            shiftDummy = 0;
        end

        X = preprocessData(validIndx,notAllZeroColumn+shiftDummy);
        Y = preprocessData(validIndx,1);

        beta = (X'*X)\(X'*Y); %OLS regression
        
        factorRts = zeros(1, size(mat,1));
        factorRts(notAllZeroColumn+shiftDummy-1) = beta;
        factorRts(allZeroColumn) = nan;
        factorRts = factorRts(alphaStartIndx:end); 

    catch
        error("dayIndx excess maximum length limit.");
    end          
end

