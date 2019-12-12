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
    factorRt(i-(day - rollingWindow) +1) = regress(rts(i-(day - rollingWindow) +2,:)',close(i-(day - rollingWindow) +1,:)');
    
    factorRegTvalue= regstats(rts(i-(day - rollingWindow) +2,:)',close(i-(day - rollingWindow) +1,:)','linear','tstat');
    tValue(i-(day - rollingWindow) +1) = factorRegTvalue.tstat.t(2); % t value of the factor return 
    pValue(i-(day - rollingWindow) +1) = factorRegTvalue.tstat.pval(2); % p value of the factor return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%1.t series%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.1 t Signaficance
% H0: mean(|t_{f_k}(T)|)=0
    summary.tSignaficance(1) = absMeanTest(tValue,10000);

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
    summary.tStationarity(2) = ADFTest(abs(tValue));

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
    summary.fkSignaficance(2) = absMeanTest(abs(factorRt),10000);

% 2.2 f_k Stationarity
% mode1:std(f_k) = 0
    [h,p] = vartest(factorRt,0,'Tail','right');
    if p < 0.05
            summary.fkStationarity(1) =1;
    else    summary.fkStationarity(1) =0;
    end

% mode2:ADF test
    summary.fkStationarity(2) = ADFTest(factorRt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3.IC序列%%%%%%%%%%%%%%%%%%%%% 
%Calculate IC of factor return
%IC(d) predict d days
    if ICmode == 1
% 3.1 IC Signaficance
% mode1: H0:mean(IC) = 0
    IC = ICValue(alpha,day,rollingWindow,d,alphaPara);
    pic = figure('visible','off');
    plot(IC);
    xlabel('rollingWindow');
    ylabel('ICValue');
    title('IC plot');
    savefig(pic, strcat('alpha_IC',num2str(fNs),'.fig'));

    [h,p,ci,stats] = ttest(IC);
            if p < 0.05
            summary.ICSignaficance(1) = 1;
                    else summary.ICSignaficance(2) = 0;
             end
% mode2: H0:|mean(IC)| = 0
     summary.ICSignaficance(2) = absMeanTest(IC,10000);

%3.2 IC Stationarity
%mode1:std(IC) = 0
     [h,p] = vartest(IC,0,'Tail','right');
            if p < 0.05
                    summary.ICStationarity(1) =1;
            else summary.ICStationarity(1) =0;
            end

%mode2: ADF test
     summary.ICStationarity(2) = ADFTest(IC);

    else ICmode == 0
% 3.1 IC Signaficance
% mode1: H0:mean(IC) = 0
    IC = rankICValue(alpha,day,rollingWindow,d,alphaPara);
    pic = figure('visible','off');
    plot(IC);
    xlabel('rollingWindow');
    ylabel('rankICValue');
    title('rankIC plot');
    savefig(pic, strcat('alpha_rankingIC',num2str(fNs),'.fig'));

    [h,p,ci,stats] = ttest(IC);
    if p < 0.05
            summary.ICSignaficance(1) = 1;
    else    summary.ICSignaficance(2) = 0;
    end
% mode2: H0:|mean(IC)| = 0
    summary.ICSignaficance(2) = absMeanTest(IC,10000);

%3.2 IC Stationarity
%mode1:std(IC) = 0
    [h,p] = vartest(IC,0,'Tail','right');
    if p < 0.05
            summary.fkStationarity(1) =1;
    else    summary.fkStationarity(1) =0;
    end
%mode2: ADF test
    summary.ICStationarity(2) = ADFTest(IC);
end
%%%%%%%%%%%%%%%%%%%%%summary SingleFactorTest%%%%%%%%%%%%%%%%%%%%%%%%%%
    summary.totalNumber = sumsummary(summary)
end

