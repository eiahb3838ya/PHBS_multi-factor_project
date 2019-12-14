classdef singleAlphaTest < handle
    
    properties
    end
    
    methods (Static)
        function resultStruct = summarySingleFactorTest(day,rollingWindow,ICmode,d,S)
            resultStruct = struct();
            fNs=fieldnames(S);
            
            for count=1:length(fNs)
                %check field size first, avoid illegal input
                alphaName = fNs{count};
                alpha = S.(fNs{count});
                X = singleAlphaTest.singleFactorTest(alpha,day,rollingWindow,ICmode,d,S,alphaName)
                resultStruct.(fNs{count}) = X;
            end
            
            dt = datestr(now,'yyyymmdd');
            filepath = pwd;
            cd('/Users/mac/Desktop/test/singleFactorReturn_testResult');
            savePath = strcat('SingleAlphaTest_result_',dt,'.mat'); % 拼接路径和文件名
            save(savePath,'resultStruct'); % 保存变量val1,val2到1_result.mat中
            %eval(['save','resultStruct',dt])
            cd(filepath);
        end
        
        function summary = singleFactorTest(alpha,day,rollingWindow,ICmode,d,alphaPara,fNs)
            % single factor test
            % get parameters from alphaPara
            try
                close = alphaPara.close;
            catch
                error 'para error';
            end
            
            %first, because no-orth, so the factor value is the factor exposure
            %the truth is that the residual of the value (orth industry, style )is the factor exposure
            [m, n] = size(alphaPara.close);
            delayclose = [zeros(1, n);alphaPara.close(1: m - 1,:)];
            rts = close./(delayclose + eps) - 1;
            
            %calculate the factor exposure
            for i = day - rollingWindow : day - 1
                factorRt(i-(day - rollingWindow) +1) = regress(rts(i-(day - rollingWindow) +2,:)',...
                    close(i-(day - rollingWindow) +1,:)');
                
                factorRegTvalue= regstats(rts(i-(day - rollingWindow) +2,:)',close(i-(day - rollingWindow) +1,:)','linear','tstat');
                tValue(i-(day - rollingWindow) +1) = factorRegTvalue.tstat.t(2); % t value of the factor return
                pValue(i-(day - rollingWindow) +1) = factorRegTvalue.tstat.pval(2); % p value of the factor return
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%1.t series%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %1.1 t Signaficance
            % H0: mean(|t_{f_k}(T)|)=0
            summary.tSignaficance(1) = singleAlphaTest.absMeanTest(tValue,10000);
            
            % 1.2 t Stationarity
            % mode 1: H0:|t| > 2
            threshold = 0.5;                 %over threshold=0.5, |t|>2  Stationary
            ratio = sum(abs(tValue)>2)/sum(length(tValue));
            if ratio > threshold
                summary.tStationarity(1) =1;
            else    summary.tStationarity(1) =0;
            end
            
            % mode 2: ADF test
            % H0: the series is not stationary.
            summary.tStationarity(2) = singleAlphaTest.ADFTest(abs(tValue));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%2.f_k factor return%%%%%%%%%%%%%%%%%%%%%
            % 2.1 f_k Signaficance
            % mode 1:直接检验f_k 的t统计量  H0:mean(f_k) = 0
            [h,p,ci,stats] = ttest(factorRt);
            if p < 0.05
                summary.fkSignaficance(1) = 1;
            else summary.fkSignaficance(1) = 0;
            end
            % mode 2:检验|f_k| 的t统计量
            % H0:|mean(f_k)| = 0
            summary.fkSignaficance(2) = singleAlphaTest.absMeanTest(abs(factorRt),10000);
            
            % 2.2 f_k Stationarity
            % mode1:std(f_k) <= 0 H1:std(f_k) > 0
            [h,p] = vartest(factorRt,0,'Tail','right');
            if p < 0.05
                summary.fkStationarity(1) =1;
            else    summary.fkStationarity(1) =0;
            end
            
            % mode2:ADF test
            summary.fkStationarity(2) = singleAlphaTest.ADFTest(factorRt);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3.IC序列%%%%%%%%%%%%%%%%%%%%%
            %Calculate IC of factor return
            %IC(d) predict d days
            if ICmode == 1
                IC = singleAlphaTest.ICValue(alpha,day,rollingWindow,d,alphaPara);
                pic = figure();
                plot(movmean(IC,5));
                xlabel('rollingWindow');
                ylabel('ICValue');
                title('IC plot');
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Desktop/test/singleFactorReturn_ICplot');
                savefig(pic, strcat('singleFactorReturn_alpha',num2str(fNs),'_IC_',dt,'.fig'));
                cd(filepath);
                
                % 3.1 IC Signaficance
                % mode1: H0:mean(IC) = 0
                [h,p,ci,stats] = ttest(IC);
                if p < 0.05
                    summary.ICSignaficance(1) = 1;
                else summary.ICSignaficance(2) = 0;
                end
                
                % mode2: H0:|mean(IC)| = 0
                summary.ICSignaficance(2) = singleAlphaTest.absMeanTest(IC,10000);
                
                %3.2 IC Stationarity
                %mode1:std(IC) = 0
                [h,p] = vartest(IC,0,'Tail','right');
                if p < 0.05
                    summary.ICStationarity(1) =1;
                else summary.ICStationarity(1) =0;
                end
                
                %mode2: ADF test
                summary.ICStationarity(2) = singleAlphaTest.ADFTest(IC);
                
                %mode3: IC > 0 or IC <0
                if sum(IC >0) == length(IC) || sum(IC <0) == length(IC);
                    summary.ICStationarity(3) =1
                else summary.ICStationarity(3) =0;
                end
                
            else ICmode == 0
                % 3.1 IC Signaficance
                % mode1: H0:mean(IC) = 0
                IC = singleAlphaTest.rankICValue(alpha,day,rollingWindow,d,alphaPara);
                pic = figure(); %'visible','off'
                plot(movmean(IC,5));
                xlabel('rollingWindow');
                ylabel('rankICValue');
                title('rankIC plot');
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Desktop/test/singleFactorReturn_ICplot');
                savefig(pic,strcat('singleFactorReturn_alpha',num2str(fNs),'_rankIC_',dt,'.fig'));
                cd(filepath);
                
                h = ttest(IC,0,'Tail','right')
                
                summary.ICSignaficance(1) = h;
                summary.ICSignaficance(2) = h;
                
                % mode2: H0:|mean(IC)| = 0
                summary.ICSignaficance(2) = singleAlphaTest.absMeanTest(IC,10000);
                
                %3.2 IC Stationarity
                %mode1:std(IC) <= threhold  H1: std(IC) > threhold
                [h,p] = vartest(IC,0,'Tail','right');
                if p < 0.05
                    summary.fkStationarity(1) =1;
                else    summary.fkStationarity(1) =0;
                end
                %mode2: ADF test
                summary.ICStationarity(2) = singleAlphaTest.ADFTest(IC);
                
                %mode3: IC > 0 or IC <0
                if sum(IC >0) == length(IC) || sum(IC <0) == length(IC);
                    summary.ICStationarity(3) =1
                else summary.ICStationarity(3) =0;
                end
                
            end
            summary.totalNumber = singleAlphaTest.sumsummary(summary)
        end
        
        function sumS = sumsummary(S)
            fNs=fieldnames(S);
            sumS=0;
            for count=1:length(fNs)
                %check field size first, avoid illegal input
                sumS=sumS+sum(sum(S.(fNs{count})));
            end
        end
        
        function IC = ICValue(alpha,day,rollingWindow,d,alphaPara)
            
            try
                close = alphaPara.close;
            catch
                error 'para error';
            end
            
            getAlpha = alpha;
            
            [m, n] = size(alphaPara.close);
            delayclose = [zeros(1, n);alphaPara.close(1: m - 1,:)];
            rts = close./(delayclose + eps) - 1;
            %rts (find(isnan(rts)==1)) = 0; % rank
            
            for i = day - rollingWindow : day - d
                x = getAlpha(i-(day - rollingWindow) +1,:);
                x(find(~isnan(x)));
                y = rts(i-(day - rollingWindow) +1 +d,:);
                y(find(~isnan(x)));
                corrMatrix = corrcoef(x,y);
                IC(i-(day - rollingWindow) +1) = corrMatrix(1,2);
            end
        end
        
        function IC = rankICValue(alpha,day,rollingWindow,d,alphaPara)
            try
                close = alphaPara.close;
                
            catch
                error 'para error';
            end
            
            getAlpha = alpha;
            [~, Xidx] = sort(getAlpha,2);
            [~,Xidx2] = sort(Xidx,2);
            getAlha = Xidx2;
            
            [m, n] = size(alphaPara.close);
            delayclose = [zeros(1, n);alphaPara.close(1: m - 1,:)];
            rts = close./(delayclose + eps) - 1;
            [~, Xidxx] = sort(rts,2);
            [~,Xidxx2] = sort(Xidxx,2);
            rts = Xidxx2;
            
            for i = day - rollingWindow : day - d
                x = getAlpha(i-(day - rollingWindow) +1,:);
                x(find(~isnan(x)));
                y = rts(i-(day - rollingWindow) +1 +d,:);
                y(find(~isnan(x)));
                corrMatrix = corrcoef(x,y);
                IC(i-(day - rollingWindow) +1) = corrMatrix(1,2);
            end
        end
        
        function signaficance = absMeanTest(m,numBootstrp)
            %H0: mean(|m|)=0
            mean(abs(m));
            mBootstrp= bootstrp(numBootstrp,@mean,abs(m));      %Bootstrap sampling
            ratio = sum(mBootstrp > 0)/numBootstrp;
            if ratio > 0.95                                     %reject H0
                signaficance = 1;
            else signaficance = 0;
            end
        end
        
        function stationarity = ADFTest(m)
            [H,pValue]=adftest(abs(m));
            if pValue < 0.05                   %reject H0, the series is stationarity
                stationarity =1;
            else stationarity =0;
            end
        end
        
    end
end