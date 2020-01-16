classdef MultiFactorModel < handle
    %MultiFactorModel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %cube
        interceptCube;
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
            %PREPROCESSENTRY, the static method will remove rows containing
            % nan or inf, and will return index(in numbers, not 0/1) of
            % different types of invalid/valid rows.
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
        %CUBE2MAT slice a cube according to its' first dimension, and
        %expand the slice into a mat
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
        %RANKCORR spearman rank coefficient
            corrMat = corr([arr1(:), arr2(:)], 'Type', 'Spearman');
            cor = corrMat(1,2);
        end
        
        function cor = commonCorr(arr1, arr2)
        %COMMONCORR return pearson linear correlation coefficient.
            corrMat = corr([arr1(:), arr2(:)], 'Type', 'Pearson');
            cor = corrMat(1,2);
        end
        
        function [] = plotCumProdRtsFromDailyRts(arr1)
        %PLOTCUMPRODRTSFROMDAILYRTS eat a series of return, the function 
        % will plot cumulative product and plot its histogram
            nonNanArr = arr1(find(~isnan(arr1)));
            cumProdRts = cumprod(1+nonNanArr);
            
            subplot(2,1,1);
            plot(cumProdRts);
            title('cumProd returns');
            
            subplot(2,1,2);
            histogram(nonNanArr, 50);
            xline(mean(nonNanArr));
            title('histogram of returns');          
        end
        
        [factorRts, validIndx] = computeOneDayFtRts(rtMat, cube, currentDayIndx, alphaStartIndx, predictionDays, stockScreen, maskShift)
        
        [oneDayModelIC, validIndx] = computeOneDayIC(stockRtMat, mixCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC, maskShift)
       
        [oneDayModelIC, validIndx] = computeOneDayICFast(stockRtMat, cube, fastCube, stockScreen, currentDayIndx, alphaStartIndx, predictionDays, icTestForwardDays, isRankIC, maskShift)
    
    end
    
    methods(Access = public)
        function obj = MultiFactorModel(rtMat, interceptFactorCube, orthFactorCube, stockScreenMat, startIndx, predictionDays, smoothingDays, isRankIC, icTestFdDays, maskShift)
            %MultiFactorModel Construct an instance of this class
            
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
                
                obj.interceptCube = interceptFactorCube;
                obj.combinedCube = cat(3,interceptFactorCube, orthFactorCube);
                disp('init success!');
            catch
                error("not enough input Args, the #input Args can only be 3 or 8");
            end
        end
        
        factorRtMat = computeAllFtRts(obj)
        
        factorRtCube = computeAllFtRtsMask(obj, alphaMaskCube)
        
        timeSeriesIC = computeNonSmoothICseries(obj)
        
        timeSeriesIC = computeSmoothICTimeSeries(obj)
        
        longShortRts = computeLongShortRts(obj, longShortPercentage, stockCloseMat)
        
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
                bins = 50;
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
                disp(['plot method deployed is: ', convertStringsToChars(plotMethod)]);
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
                    [oneDayExpectRts, ~] = MultiFactorModel.computeOneDayIC(obj.rtMat, obj.combinedCube, obj.stockScreen, dayIndx, obj.alphaStartIndex, obj.predictionDays, obj.icTestForwardDays, -1, obj.maskShift);
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

