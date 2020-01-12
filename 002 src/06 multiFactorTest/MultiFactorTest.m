classdef MultiFactorTest < handle
    %MULTIFACTORTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %cube
        combinedCube;
        
        %mat
        rtMat;
        stockScreen;
        
        %int
        startIndx; %date start index
        maskShift;
        alphaStartIndex;
        predictionDays;
        smoothingDays;
        icTestForwardDays;
        
        %bool
        isRankIC;
    end
    
    methods(Static)
        function [validIndx, nanIndx, infIndx] = preprocessEntry(mat)
            %PREPROCESSENTRY 
            %   mat is 2d
            rowLength = size(mat,1);
            nanIndx = find(sum(isnan(mat),2)~=0);
            infIndx = find(sum(isinf(mat),2)~=0);
            indxNotUse = unique([nanIndx; infIndx]);

            if ~isempty(indxNotUse)
                validIndx = setdiff(1:rowLength, indxNotUse);
            else
                validIndx = 1:rowLength;
            end
        end
        
        function X = cube2Mat(cube, indx)
        %CUBE2MAT return a mat
            try
                cubeToUse = cube(indx,:,:);

                depth = size(cubeToUse,3);
                dim2Length = size(cubeToUse,2);

                %permute table and reshape
                cubeToUseTranspose = permute(cubeToUse, [2,1,3]);
                X = reshape(cubeToUseTranspose, [dim2Length, depth]);
                X = X';
            catch
                error("indx excess maximum length of given axis");
            end
        end
        
        function cor = rankCorr(arr1, arr2)
            % spearman rank coefficient
            corrMat = corr([arr1(:), arr2(:)], 'Type', 'Spearman');
            cor = corrMat(1,2);
        end
        
        function cor = commonCorr(arr1, arr2)
            corrMat = corr([arr1(:), arr2(:)], 'Type', 'Pearson');
            cor = corrMat(1,2);
%             cor = corrcoef(arr1(:), arr2(:));
%             cor = cor(1,2);
        end
        
        function [factorRts, validIndx] = computeOneDayFtRts(rtMat, cube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskShift)
            %COMPUTEONEDAYFTRTS  computeOneDayFtRts(rtMat, cube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskPredictShift)
            % note how the matrix look like
            if nargin == 4
                predictionDays = 1;
                stockScreen = ones(size(rtMat));
                maskShift = -1*predictionDays;
            end
            
            try
                %cube like days by stocks by features
                mat = MultiFactorTest.cube2Mat(cube, currentDayIndx - predictionDays); %mat: features by stocks
                dayRts = rtMat(currentDayIndx,:); %dayRts: 1 by stocks

                % preprocess data
                % disp(['process day: ', num2str(currentDayIndx)]);
                preprocessData = [dayRts',mat']; % [stock by 1, stock by features]
                
                % stock screen mask
                stockScreenOneDay = stockScreen(currentDayIndx+maskShift,:);
                
                stockScreenValidIndx = find(stockScreenOneDay==1);
                
                [nanInfValidIndx, ~, ~] = MultiFactorTest.preprocessEntry(preprocessData);%pick by stock's num

                validIndx = intersect(nanInfValidIndx, stockScreenValidIndx);
                
                % get x, y for regression
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

                beta = (X'*X)\(X'*Y);

                factorRts = zeros(1, size(mat,1));
                factorRts(notAllZeroColumn+shiftDummy-1) = beta;
                factorRts(allZeroColumn) = nan;
                factorRts = factorRts(alphaStartIndx:end); 
                
            catch
                error("dayIndx excess maximum length limit.");
            end          
        end
        
        function [oneDayModelIC, validIndx] = computeOneDayIC(stockRtMat, mixCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC, maskShift)
        % COMPUTEONEDAYIC computeOneDayIC(stockRtMat, mixCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC)
            if nargin == 5
                predictionDays = 1;
                maskShift = -1*predictionDays;
                icTestForwardDays = 1;
                isRankIC = 1;
            end
            
            % factor rts, length is #features
            [factorRts, ~] = MultiFactorTest.computeOneDayFtRts(stockRtMat, mixCube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskShift);

            % get stock return ready to test IC
            % get stock exposure of size stocks by features
            icDayForwardStockRt = stockRtMat(currentDayIndx + icTestForwardDays,:); %1 by stocks,R_t+1
            oneDayFactorExposure = MultiFactorTest.cube2Mat(mixCube(:,:,alphaStartIndx:end), currentDayIndx); %features by stocks
            
            % get valid stock 
            stockScreenOneDay = stockScreen(currentDayIndx,:);
            stockScreenValidIndx = find(stockScreenOneDay==1);
            [nanInfValidIndx, ~, ~] = MultiFactorTest.preprocessEntry([icDayForwardStockRt',oneDayFactorExposure']);%pick by stock's num
            validIndx = intersect(nanInfValidIndx, stockScreenValidIndx);
            
            if isRankIC == -1
                oneDayModelIC = oneDayFactorExposure'*factorRts';
                return;
            end
            
            rtsContributedByFts = oneDayFactorExposure(:,validIndx)'*factorRts'; %column vector

            icStockRts = icDayForwardStockRt(validIndx);
            icFtRts = rtsContributedByFts;

            if isRankIC == 1
                oneDayModelIC = MultiFactorTest.rankCorr(icStockRts, icFtRts);
            elseif isRankIC == 0
                oneDayModelIC = MultiFactorTest.commonCorr(icStockRts, icFtRts);
            else
                error("isRankIC can only be 0 or 1 or -1");
            end    
        end
        
    end
    
    methods(Access = public)
        function obj = MultiFactorTest(rtMat, interceptFactorCube, orthFactorCube, stockScreenMat, startIndx, predictionDays, smoothingDays, isRankIC, icTestFdDays, maskShift)
            %MULTIFACTORTEST Construct an instance of this class
            
            %an empty start up
            if nargin == 0
                disp("an empty constructor starts!");
                return;
            end
            
            if nargin == 3
                % give a default version
                stockScreenMat = ones(size(rtMat));
                startIndx = 800;
                predictionDays = 1;
                smoothingDays = 50;
                isRankIC = 1;
                maskShift = -1*predictionDays;
            end
            
            try
                obj.rtMat = rtMat;
                obj.stockScreen = stockScreenMat;
                obj.startIndx = startIndx;
                obj.predictionDays = predictionDays;
                obj.smoothingDays = smoothingDays;
                obj.isRankIC = isRankIC;
                obj.icTestForwardDays = icTestFdDays;
                obj.alphaStartIndex = size(interceptFactorCube,3)+1;
                obj.maskShift = maskShift;
                
                disp('multiFactor Module start:');
                disp(['start index is: ', num2str(obj.startIndx)]);
                disp(['to predict ', num2str(obj.predictionDays), ' day afterforwards']);
                disp(['compare IC with stock returns ', num2str(obj.icTestForwardDays), ' day later.']);
                disp(['factor return moving average period is ', num2str(obj.smoothingDays)]);
                disp(['rank IC status ', num2str(obj.isRankIC)]);
                disp(['mask shift is ', num2str(obj.maskShift)]);
                
                obj.combinedCube = cat(3,interceptFactorCube, orthFactorCube);
                disp('init success!');
            catch
                error("not enough input Args, the #input Args can only be 3 or 8");
            end
        end
        
        function factorRtMat = computeAllFtRts(obj)
            
            % get total days and total features a day
            totalDays = size(obj.rtMat,1);
            totalFeatures = size(obj.combinedCube,3) - obj.alphaStartIndex + 1;
            
            % it's like, the first pDays rows do not exist
            factorRtMat = nan*zeros(totalDays, totalFeatures);
            
            % init a waiting bar
            h=waitbar(0,'please wait');
            
            for dayIndx = obj.startIndx+obj.predictionDays : totalDays
                % run regression
                [oneDayFtRts,~] = MultiFactorTest.computeOneDayFtRts(obj.rtMat, obj.combinedCube, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.stockScreen, obj.maskShift);
                factorRtMat(dayIndx,:) = oneDayFtRts;
                
                % wait bar information
                str=['process day: ',num2str(dayIndx),'/',num2str(totalDays)];
                waitbar(dayIndx/totalDays,h,str);
            end
            
            close(h);
            
        end
        
        function timeSeriesIC = computeNonSmoothICseries(obj)
            
            %get total days
            totalDays = size(obj.rtMat,1);
            
            %get IC series
            icArray = nan*ones(totalDays,1);
            
            % init a waiting bar
            h=waitbar(0,'please wait');
            
            for dayIndx = obj.startIndx+obj.predictionDays : totalDays-obj.icTestForwardDays
                %run IC mode
                % stockRtMat, mixCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC
                [icOneDay,~] = MultiFactorTest.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, obj.isRankIC, obj.maskShift);
                icArray(dayIndx) = icOneDay;
                
                % wait bar information
                str=['process day: ',num2str(dayIndx),'/',num2str(totalDays-obj.icTestForwardDays)];
                waitbar(dayIndx/totalDays,h,str);
            end
            
            timeSeriesIC = icArray;
            
        end
        
        function timeSeriesIC = computeSmoothICTimeSeries(obj)
            
            %indicate smoothing period
            disp(['compute IC, smoothing periods: ',num2str(obj.smoothingDays)]);
            disp(['compute IC, is rank IC: ', num2str(obj.isRankIC)]);
            
            %total days
            totalDays = size(obj.rtMat, 1);
            totalStocks = size(obj.rtMat, 2);
            
            %store 2 things, valid index and stock returns separately
            timeSeriesIC = nan*zeros(totalDays,1);
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
            for dayIndx = obj.startIndx + obj.predictionDays:totalDays - obj.icTestForwardDays
                % get one day expected factor returns
                [oneDayExpectRts, oneDayValidIndx] = MultiFactorTest.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, -1, obj.maskShift);
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
                    timeSeriesIC(currentDayIndx) = MultiFactorTest.commonCorr(sum(periodValidExpectedRts,2), obj.rtMat(currentDayIndx+obj.icTestForwardDays,periodValidIndx));
                elseif obj.isRankIC == 0
                    timeSeriesIC(currentDayIndx) = MultiFactorTest.rankCorr(sum(periodValidExpectedRts,2), obj.rtMat(currentDayIndx+obj.icTestForwardDays,periodValidIndx));
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
        
        function longShortRts = computeAllLSRts(obj, longShortPercentage, stockCloseMat)
            % position change interval is the same as the prediction
            % interval
            
            %total days
            totalDays = size(obj.rtMat, 1);
            totalStocks = size(obj.rtMat, 2);
            longShortRts = nan*ones(totalDays, 1));
            
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
            for dayIndx = obj.startIndx + obj.predictionDays:totalDays
                % get one day expected factor returns
                [oneDayExpectRts, oneDayValidIndx] = MultiFactorTest.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, -1, obj.maskShift);
                allDayExpectRts{dayIndx} = oneDayExpectRts;
                allValidIndx{dayIndx} = oneDayValidIndx;
                
                % wait bar information
                str=['factor return, process day: ',num2str(dayIndx),'/',num2str(totalDays)];
                waitbar(dayIndx/totalDays,h,str);
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
                toSort = [allDayExpectRts{decideTradeDay}(:),allValidIndx{decideTradeDay}(:)];
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
        
        function icSeries = plotDifferentICDays(obj, icPredictArray, isSmooth, isPlot)
            disp(['is rank IC: ', num2str(obj.isRankIC)]);
            if nargin < 4
                isPlot = 3;
            end
            icSeries = cell(1, length(icPredictArray));
            if isSmooth == 1
                for icCount = 1:length(icPredictArray)
                    obj.icTestForwardDays = icPredictArray(icCount);
                    icSeries{icCount} = obj.computeSmoothICTimeSeries();
                end
            else
                for icCount = 1:length(icPredictArray)
                    obj.icTestForwardDays = icPredictArray(icCount);
                    icSeries{icCount} = obj.computeNonSmoothICseries();
                end
            end
            
            if isPlot
                bins = 10;
                rowNumber = length(icPredictArray) / 2;
                for i = 1:length(icPredictArray)
                    subplot(rowNumber, 2, i);
                    icToday = icSeries{i};
                    histogram(icToday(find(~isnan(icToday))), bins);
                    xline(mean(icToday(find(~isnan(icToday)))));
                    text(mean(icToday(find(~isnan(icToday)))), 500, ['mean:',num2str(round(mean(icToday(find(~isnan(icToday)))),4))]);
                    title(['ic =', num2str(icPredictArray(i))]);
                end
            end
        end
        
        function cumFtRtSeries = plotCumFtRtSeries(obj, plotMethod)
            
            % validate the input params
            if ~contains(plotMethod, ["marketPortfolio","cumProd"])
                error("plotMethod must be either marketPortfolio or cumProd");
            else
                disp(['plot method deployed is: ', convertCharsToStrings(plotMethod)]);
            end
            
            if strcmp(plotMethod, "marketPortfolio")
                %total days
                totalDays = size(obj.rtMat, 1);

                % init a new variable to store.
                cumFtRtSeries = nan*zeros(totalDays, 1);

                % init a wait bar
                h=waitbar(0,'step 1 of 2,computing factor return:');

                % calculate every day return
                for dayIndx = obj.startIndx + obj.predictionDays:totalDays - obj.icTestForwardDays
                    % get one day expected factor returns
                    [oneDayExpectRts, ~] = MultiFactorTest.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, -1, obj.maskShift);
                    cumFtRtSeries(dayIndx) = mean(oneDayExpectRts, 'omitnan');

                    % wait bar information
                    str=['factor return, process day: ',num2str(dayIndx),'/',num2str(totalDays - obj.icTestForwardDays)];
                    waitbar(dayIndx/(totalDays-obj.icTestForwardDays),h,str);
                end

                %close wait bar
                close(h);
                
                plot(cumprod(1+cumFtRtSeries(find(~isnan(cumFtRtSeries)))));
                title('cumulative factor return: market portfolio way');
            else
                cumFtRtSeries = obj.computeAllFtRts();
                
                if size(cumFtRtSeries,2)>1
                    error("cumProd method can only work for single factor test.");
                end
                
                plot(cumprod(1+cumFtRtSeries(find(~isnan(cumFtRtSeries)))));
                title('cumulative factor return: cumProd way');
            end
        end
    end
end

