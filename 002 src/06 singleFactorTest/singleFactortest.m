classdef singleFactorTest < handle
    properties
        %private
        %cube
        processedAlphas;
        industryCube;
        styleCube;
        alphaNameList;
        
        %mat
        processedClose;
        returnClose;
        factorReturn;
        stockScreen;
        
        %public
        startTime;
        ICpredictDays;
        ICmode;
    end
    
    methods(Static)
        function rts = calRts(processedClose, starttime)
            targetClose = processedClose.close(end-starttime +1:end,:);
            closeYesterday = processedClose.close(end-starttime:end-1,:);
            rts = targetClose ./ closeYesterday -1;
        end
        
%         function orderY = calOrder(Y)
%             [~,rankY] = sort(Y);
%             toSortRow = [rankY',(1:length(rankY))'];
%             sortedMat = sortrows(toSortRow, 1);
%             orderY = sortedMat(:, 2)';
%         end
        
        function cor = rankCorr(arr1, arr2)
            % spearman rank coefficient
            corrMat = corr([arr1(:), arr2(:)], 'Type', 'Spearman');
            cor = corrMat(1,2);
        end
    end
    
    methods
        function obj = singleFactorTest(processedAlphas, processedClose, startTime,ICpredictDays,ICmode,stockScreen,industryFactor,styleFactor, alphaNameList)
            %constructor
            obj.alphaNameList = alphaNameList;
            obj.processedAlphas = processedAlphas;
            obj.industryCube = industryFactor;
            obj.styleCube = styleFactor;
            obj.stockScreen = stockScreen;
            
            if nargin >1
                obj.processedClose = processedClose;
            else
                obj.processedClose = load('cleanedData_stock_20191217.mat');
            end
            
            if nargin >2
                obj.startTime = startTime;
            else
                obj.startTime = 500;
            end
            
            if nargin >3
                obj.ICpredictDays = ICpredictDays;
            else
                obj.ICpredictDays = 1;
            end
            
            if nargin >4
                obj.ICmode = ICmode;
            else
                obj.ICmode = 1;
            end
            
            obj.returnClose = obj.calRts(obj.processedClose, obj.startTime);
        end
        
        %calculate the IC for singleFactor
        function IC = ICValue(obj,alphaTable,ICpredictDays,ICmode)
            %getAlpha = alphaTable(end-obj.startTime +1:end,:);
            getValidAlpha = getMask(obj,alphaTable);
            %Normal IC:IC mode ==0
            if obj.ICmode == 0
                [factorReturn,tValue] = calFactorReturn(obj,alphaTable); %200 第一个是0
                for i =  2: obj.startTime - obj.ICpredictDays  %2:199 从第3天才有IC
                    BigMatrix = [getValidAlpha(i,:).*factorReturn(i);obj.returnClose(i + obj.ICpredictDays,:)];
                    colRow = sum(isinf(BigMatrix),1)>0;
                    BigMatrix(:,colRow) = [];
                    BigMatrix = rmmissing(BigMatrix,2);
                    corrMatrix = corrcoef(BigMatrix(1,:),BigMatrix(2,:));
                    IC(i) = corrMatrix(1,2);
                    meanPortfolio = mean(BigMatrix(1,:));
                end
                
                %rank IC:IC mode ==1
            else obj.ICmode == 1
                [factorReturn,tValue] = calFactorReturn(obj,alphaTable);
                for i =  2: obj.startTime - obj.ICpredictDays
                    BigMatrix = [getValidAlpha(i,:).*factorReturn(i);obj.returnClose(i + obj.ICpredictDays,:)];
                    colRow = sum(isinf(BigMatrix),1)>0;
                    BigMatrix(:,colRow) = [];
                    BigMatrix = rmmissing(BigMatrix,2);
                    IC(i) = obj.rankCorr(BigMatrix(1,:), BigMatrix(2,:));
                    %                     X = BigMatrix(1,:);
                    %                     orderX = obj.calOrder(X);
                    %
                    %                     Y = BigMatrix(2,:);
                    %                     orderY = obj.calOrder(Y);
                    %
                    %                     corrMatrix = corrcoef(orderX,orderY);
                    %                     IC(i) = corrMatrix(1,2);
                end
            end
        end
        
        %Calculate AllFactor(number = m) IC and the result is a ICTable (m * starttime)
        function ICTable = calAllFactorIC(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                disp(strcat('This is_',num2str(j),'_alpha'));
                ICTable(j,:) = ICValue(obj,obj.processedAlphas(:,:,j),obj.ICpredictDays,obj.ICmode);
            end
            
            dt = datestr(now,'yyyymmdd');
            filepath = pwd;
            cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_testResult');
            savePath = strcat('SingleAlphaTest_ICValue_',dt,'.mat');
            save(savePath,'ICTable');
            cd(filepath);
        end
        
        function plotIC(obj,ICpredictDays,ICmode)
            ICTable = calAllFactorIC(obj);
            [~,~,alphaCount] = size(obj.processedAlphas);
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                IC = ICTable(i,:);
                plot(IC(2:end));
                ylim=get(gca,'Ylim');
                hold on
                plot(xlim,[0,0],'m--'); %abline y = 0
                hold on
                
                xlabel('startTime');
                
                if obj.ICmode ==0
                    ylabel('NormalICValue');
                    title(strcat('NormalIC plot' ,obj.alphaNameList{i}));
                    
                else obj.ICmode == 1
                    ylabel('rankICValue');
                    title(strcat('rankIC plot' ,obj.alphaNameList{i}));
                end
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_ICplot');
                savefig(pic, strcat('singleFactorPlot_',obj.alphaNameList{i},'_ICmode=',num2str(obj.ICmode),'_',dt,'.fig'));
                cd(filepath);
            end
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                IC = ICTable(i,:);
                histogram(IC(3:end));
                xlabel('startTime');
                
                if obj.ICmode ==0
                    ylabel('NormalIC Value');
                    title(strcat('NormalIC histogram' ,obj.alphaNameList{i}));
                    
                else obj.ICmode == 1
                    ylabel('rankIC Value');
                    title(strcat('rankIC histogram' ,obj.alphaNameList{i}));
                end
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_ICplot');
                savefig(pic, strcat('singleFactorHistogram_',obj.alphaNameList{i},'_ICmode=',num2str(obj.ICmode),'_',dt,'.fig'));
                cd(filepath);
            end
        end
        
        function BigCubeSlice = catIndustryStyleCube(obj)
            BigCube = cat(3,obj.industryCube, obj.styleCube);
            BigCubeSlice = BigCube(end-obj.startTime +1:end,:,:);
        end
        
        function getValidAlpha = getMask(obj,alphaTable)
            toMask = obj.stockScreen(end-obj.startTime +1:end,:);
            getAlpha = alphaTable(end-obj.startTime +1:end,:);
            toMask(toMask==0)=nan;
            getValidAlpha = toMask .* getAlpha;
        end
        
        function [factorReturn,tValue] = calFactorReturn(obj,alphaTable)
            getValidAlpha = getMask(obj,alphaTable);
            
            [m,~] = size(getValidAlpha);
            BigCubeSlice = catIndustryStyleCube(obj);
            for i = 2:m
                ReshapeBigCubeSlice = BigCubeSlice(i-1,:,:);
                reshapeBigCube = reshape(ReshapeBigCubeSlice,size(ReshapeBigCubeSlice,2),size(ReshapeBigCubeSlice,3),1);
                BigMatrix =[reshapeBigCube,getValidAlpha(i-1,:)',obj.returnClose(i,:)'];
                infRow = sum(isinf(BigMatrix),2)>0;
                BigMatrix(infRow,:) = [];
                
                BigMatrix = rmmissing(BigMatrix,1);
                colIndex = find(sum(abs(BigMatrix))~=0);
                BigMatrix = BigMatrix(:,colIndex);
                
                factorReturnAll = regress((BigMatrix(:,end)),(BigMatrix(:,1:end-1)));
                factorReturn(i) = factorReturnAll(end); %1 dont' have factor return
                factorRegTvalue= regstats((BigMatrix(:,end)),(BigMatrix(:,1:end-1)),'linear','tstat');
                tValue(i) = factorRegTvalue.tstat.t(2);
            end
            %disp("cal factor Return")
        end
        
        function cumlongShortReturn = callongShortReturn(obj,alphaTable)
            [factorReturn,tValue] = calFactorReturn(obj,alphaTable);
            %getAlpha = alphaTable(end-obj.startTime +1:end,:);
            getValidAlpha = getMask(obj,alphaTable);
            group = 10;
            for i =  2: obj.startTime - obj.ICpredictDays
                AlphaExplainPart = factorReturn(i)* getValidAlpha(i,:);
                nextTimeRealReturn = obj.returnClose(i+1,:);
                
                bigMatrix = [AlphaExplainPart;nextTimeRealReturn];
                bigMatrix = rmmissing(bigMatrix,2);
                [~,infCol] = find(isinf(bigMatrix));
                bigMatrix(:,infCol) = [];
                
                %[rankX;1:length(X)]
                %rankX是X中rank的对应位置
                X = bigMatrix(1,:);
                Y = bigMatrix(2,:);
                [sortX,rankX] = sort(X);
                toSortRow = [rankX',(1:length(rankX))'];
                sortedMat = sortrows(toSortRow, 1);
                orderX = sortedMat(:, 2)';
                weight = [];
                n = length(X);
                
                leftSide = orderX <= round(n/group);
                leftSide = leftSide * -1;
                leftnum = sum(sum(leftSide~=0));
                rightSide = orderX > round(n - n/group);
                rightnum = sum(sum(rightSide~=0));
                weight = leftSide + rightSide;
                longShortReturn(i) = sum(weight * Y') / (rightnum + leftnum);
            end
            cumlongShortReturn = cumprod(longShortReturn + 1) /(1+ longShortReturn(1));
        end
        
        function cumlongShortReturnTable = calAllcumlongShortReturn(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                cumlongShortReturnTable(j,:) = callongShortReturn(obj,obj.processedAlphas(:,:,j));
            end
        end
        
        function plotAllcumlongShortReturnTable(obj)
            cumlongShortReturnTable = calAllcumlongShortReturn(obj);
            [~,~,alphaCount] = size(obj.processedAlphas);
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                cumLongShortReturn = cumlongShortReturnTable(i,:);
                plot(cumLongShortReturn);
                
                xlabel('startTime');
                ylabel('cumlongShortReturn cumprod returns');
                title(strcat('cumLongShort FactorReturnPlot' ,obj.alphaNameList{i}));
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                %cd('./002 src/05 singleFactorTest/singleFactorReturn_cumFactorReturnPlot');
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_cumFactorReturnPlot');
                savefig(pic, strcat('singleFactorReturn_cumLongShort_FactorReturnPlot_',obj.alphaNameList{i},'_',dt,'.fig'));
                cd(filepath);
            end
        end
        
        function summary = statTest(obj,alphaTable)
            [factorReturn,tValue] = calFactorReturn(obj,alphaTable);
            
            factorReturn = factorReturn(2:end);
            tValue = tValue(2:end);
            
            %t Signaficance
            %H0: mean(|t_{f_k}(T)|)=0
            summary.tSignaficance(1) = absMeanTest(tValue,10000);
            
            %t Stationarity
            % mode 1: H0:|t| > 2
            threshold = 0.5;  %over threshold=0.5, |t|>2  Stationary
            ratio = sum(abs(tValue)>2)/sum(length(tValue));
            if ratio > threshold
                summary.tStationarity(1) =1;
            else summary.tStationarity(1) =0;
            end
            
            % mode 2: ADF test
            % H0: the series is not stationary.
            % summary.tStationarity(2) = ADFTest(abs(tValue));
            
            %f_k Signaficance
            % mode 1:test f_k t statistics  H0:mean(f_k) = 0
            [h,p,ci,stats] = ttest(obj.factorReturn);
            if p < 0.05
                summary.fkSignaficance(1) = 1;
            else summary.fkSignaficance(1) = 0;
            end
            % mode 2: H0:|mean(f_k)| = 0
            summary.fkSignaficance(2) = absMeanTest(abs(factorReturn),10000);
            
            %f_k Stationarity
            % mode1:std(f_k) = 0
            summary.fkStationarity(1) = stdTest(factorReturn,10000,0.02);
            % mode2:ADF test
            %summary.fkStationarity(2) = ADFTest(factorReturn);
            
            IC = ICValue(obj,alphaTable);
            % IC Signaficance
            % mode1: H0:mean(IC) = 0
            [h,p,ci,stats] = ttest(IC);
            if p < 0.05
                summary.ICSignaficance(1) = 1;
            else summary.ICSignaficance(2) = 0;
            end
            
            % mode2: H0:|mean(IC)| = 0
            summary.ICSignaficance(2) = absMeanTest(IC,10000);
            
            %IC Stationarity
            %mode1:std(IC) = 0
            [h,p] = vartest(IC,0,'Tail','right');
            if p < 0.05
                summary.ICStationarity(1) =1;
            else summary.ICStationarity(1) =0;
            end
            
            %mode2: ADF test
            %summary.ICStationarity(2) = ADFTest(IC);
            
            %mode3: IC > 0 or IC <0
            if sum(IC >0) == length(IC) || sum(IC <0) == length(IC);
                summary.ICStationarity(3) =1;
            else summary.ICStationarity(3) =0;
            end
            summary.totalNumber = sumsummary(summary);
        end
        
        function allAlphaStatResult = sumAlphaStatResult(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                allAlphaStatResult(j) = statTest(obj,obj.processedAlphas(:,:,j));
            end
        end
        
        function saveResult = saveAllAlphaStatResult(obj)
            AlphaStatResult = sumAlphaStatResult(obj);
            dt = datestr(now,'yyyymmdd');
            filepath = pwd;
            cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_testResult');
            savePath = strcat('SingleAlphaTest_result_',dt,'.mat');
            save(savePath,'AlphaStatResult');
            cd(filepath);
        end
        
        function cumFactorReturn = calCumFactorReturn(obj,alphaTable)
            [factorReturn,~] = calFactorReturn(obj,alphaTable);
            factorReturn = factorReturn(:,2:end);
            cumFactorReturn = cumprod(factorReturn +1) /(1+ factorReturn(1));
        end
        
        function cumFactorReturnTable = calAllCumFactorReturn(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                cumFactorReturnTable(j,:) = calCumFactorReturn(obj,obj.processedAlphas(:,:,j));
            end
        end
        
        function plotAllCumFactorReturn(obj)
            cumFactorReturnTable = calAllCumFactorReturn(obj);
            [~,~,alphaCount] = size(obj.processedAlphas);
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                cumFactorReturn = cumFactorReturnTable(i,:);
                plot(cumFactorReturn);
                xlabel('startTime');
                ylabel('Factor cumprod returns');
                title(strcat('cumFactorReturnPlot' ,obj.alphaNameList{i}));
                %title(strcat('cumFactorReturnPlot_' ,obj.alphaNameList{i}));
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                %cd('./002 src/05 singleFactorTest/singleFactorReturn_cumFactorReturnPlot');
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_cumFactorReturnPlot');
                savefig(pic, strcat('singleFactorReturn_cumFactorReturnPlot_',obj.alphaNameList{i},'_',dt,'.fig'));
                cd(filepath);
            end
        end
    end
end
