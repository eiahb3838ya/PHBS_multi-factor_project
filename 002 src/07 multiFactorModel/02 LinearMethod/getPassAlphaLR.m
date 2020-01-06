function getPassAlphaLR(exposure, alphaName,close,startTime,mode)
% mode 1 = LASSO  mode 2 = Ridge
passAlphaNumber = alphaSelect(exposure,close,alphaName,startTime,mode);
[m,n,p] = size(exposure);
for i = 2 : startTime
    saveSelectAlpha{i} = alphaName(passAlphaNumber(:,i));
end

dt = datestr(now,'yyyymmdd');
filepath = pwd;
cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/06 multiFactorTest/LinearMethod');
savePath = strcat('corrAlphaTest_result_','mode=',num2str(mode),'_',dt,'.mat');
save(savePath,'saveSelectAlpha');
cd(filepath);
end

%for time loop
function alphaSmallCube = getAlphaTable(exposure,startTime)
[m,n,p] = size(exposure);
alphaSmallCube = exposure(m-startTime +1:m,:,:);
end

function rts = calRts(close, startTime)
[time,~] = size(close);
targetClose = close(time-startTime +1:time,:);
closeYesterday = close(time-startTime:time-1,:);
rts = targetClose ./ closeYesterday -1;
rts = rts';
end


% get one alphaTable
function passAlphaNumber = alphaSelect(exposure,close,alphaName,startTime,mode)
alphaSmallCube = getAlphaTable(exposure,startTime);
rts = calRts(close, startTime);

for i = 2 : startTime
    everyDayRts = rts(:,i);  % 2 to 100, 1 to 99
    reshapeAlphaTable = reshape(alphaSmallCube(i-1,:,:),[size(exposure,2),size(exposure,3),1]);
    bigMatrix = [everyDayRts , reshapeAlphaTable];
    bigMatrix = rmmissing(bigMatrix,1);
    
    if mode == 1 %LASSO
        disp('please wait the calculation of LASSO is slow :)')
        [B,FitInfo] = lasso(bigMatrix(:,2:end),bigMatrix(:,1),'CV',10);
        %     fig = figure;
        %     lassoPlot(B,FitInfo,'PlotTyle','CV');
        %     legend('show');
        idxLambda1SE = FitInfo.Index1SE;
        coef = B(:,idxLambda1SE);
        passAlphaNumber(:,i) = coef~=0
        
    else mode == 2 %Ridge
        disp('the calculation of Ridge is really quick~')
        k = 0.001;
        B = ridge(bigMatrix(:,1),bigMatrix(:,2:end),k);
        %     pic = figure;
        %     plot(B)
        %     hold on
        %     plot(xlim,[0,0],'m--'); %abline y = 0
        %     xlabel('alphaIndex');
        passAlphaNumber(:,i) = B(1:29,:) > abs(2e-04);
    end
end
end



