classdef singleFactorTest < handle
    properties
        %private
        %cube
        processedAlphas;
        
        %mat
        processedClose;
        returnClose;
        factorReturn;
        
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
    end
    
    methods
        function obj = singleFactorTest(processedAlphas, processedClose, startTime,ICpredictDays,ICmode)
            %constructor
            obj.processedAlphas = processedAlphas;
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
            disp("cal return close")
        end
        
        %calculate the IC for singleFactor
        function IC = ICValue(obj,alphaTable,ICpredictDays,ICmode)
            getAlpha = alphaTable(end-obj.startTime +1:end,:);
            
            %Normal IC:IC mode ==0
            if obj.ICmode == 0
                for i =  1: obj.startTime - obj.ICpredictDays
                    BigMatrix = [getAlpha(i,:);obj.returnClose(i + obj.ICpredictDays,:)];
                    BigMatrix = rmmissing(BigMatrix,2);
                    corrMatrix = corrcoef(BigMatrix(1,:),BigMatrix(2,:));
                    IC(i) = corrMatrix(1,2);
                end
                
                %rank IC:IC mode ==1
            else obj.ICmode == 1
                for i =  1: obj.startTime - obj.ICpredictDays
                    BigMatrix = [getAlpha(i,:);obj.returnClose(i + obj.ICpredictDays,:)];
                    BigMatrix = rmmissing(BigMatrix,2);
                    [~,Alpharank] = sort(BigMatrix(1,:));
                    [~,Returnrank] = sort(BigMatrix(2,:));
                    corrMatrix = corrcoef(Alpharank,Returnrank);
                    IC(i) = corrMatrix(1,2);
                end
            end
            %disp("cal IC")
        end
        
        %Calculate AllFactor(number = m) IC and the result is a ICTable (m * starttime)
        function ICTable = calAllFactorIC(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                ICTable(j,:) = ICValue(obj,obj.processedAlphas(:,:,j),obj.ICpredictDays,obj.ICmode);
            end
        end
        
        function plotIC(obj,ICpredictDays,ICmode)
            ICTable = calAllFactorIC(obj);
            [~,~,alphaCount] = size(obj.processedAlphas);
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                IC = ICTable(i,:);
                plot(movmean(IC,5));
                xlabel('startTime');
                
                if obj.ICmode ==0
                    ylabel('NormalICValue');
                    title('NormalIC plot');
                    
                else obj.ICmode == 1
                    ylabel('rankICValue');
                    title('rankIC plot');
                end
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_ICplot');
                savefig(pic, strcat('singleFactorPlot_',num2str(i),'_ICmode=',num2str(obj.ICmode),'_',dt,'.fig'));
                cd(filepath);
            end
        end
        
        %cumFactorReturnPlot
        function [factorReturn,tValue] = calFactorReturn(obj,alphaTable)
            getAlpha = alphaTable(end-obj.startTime +1:end,:);
            [m,~] = size(getAlpha);
            for i = 1:m-1
                BigMatrix = [getAlpha(i,:);obj.returnClose(i+1,:)];
                BigMatrix = rmmissing(BigMatrix,2);
                factorReturn(i) = regress((BigMatrix(2,:))',(BigMatrix(1,:))');
                factorRegTvalue= regstats((BigMatrix(2,:))',(BigMatrix(1,:))','linear','tstat');
                tValue(i) = factorRegTvalue.tstat.t(2);
            end
            %disp("cal factor Return")
        end
        
        function summary = statTest(obj,alphaTable)
            [~,tValue] = calFactorReturn(obj,alphaTable);
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
            summary.tStationarity(2) = ADFTest(abs(tValue));
            
            %f_k Signaficance
            % mode 1:test f_k t statistics  H0:mean(f_k) = 0
            [h,p,ci,stats] = ttest(obj.factorReturn);
            if p < 0.05
                summary.fkSignaficance(1) = 1;
            else summary.fkSignaficance(1) = 0;
            end
            % mode 2: H0:|mean(f_k)| = 0
            summary.fkSignaficance(2) = absMeanTest(abs(obj.factorReturn),10000);
            
            %f_k Stationarity
            % mode1:std(f_k) = 0
            summary.fkStationarity(1) = stdTest(obj.factorReturn,10000,0.02);
            % mode2:ADF test
            summary.fkStationarity(2) = ADFTest(obj.factorReturn);
            
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
            summary.ICStationarity(2) = ADFTest(IC);
            
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
            savePath = strcat('SingleAlphaTest_result_',dt,'.mat'); % 拼接路径和文件名
            save(savePath,'AlphaStatResult'); % 保存变量val1,val2到1_result.mat中
            %eval(['save','resultStruct',dt])
            cd(filepath);
        end
        
        function cumFactorReturn = calCumFactorReturn(obj,alphaTable)
            [factorReturn,~] = calFactorReturn(obj,alphaTable)
            cumFactorReturn = cumprod(factorReturn + 1) /(1+ factorReturn(1));
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
                title('cumFactorReturnPlot');
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_cumFactorReturnPlot');
                savefig(pic, strcat('singleFactorReturn_cumFactorReturnPlot_',num2str(i),'_',dt,'.fig'));
                cd(filepath);
            end
            
        end
    end
end
