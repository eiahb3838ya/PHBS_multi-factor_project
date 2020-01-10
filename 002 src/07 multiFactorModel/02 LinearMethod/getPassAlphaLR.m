% getTotalAlpha.exposure = exposure;
% getTotalAlpha.alphaName = alphaNameList;
% getTotalAlpha.stockReturn = stockReturn;
% getTotalAlpha.startTime = 200;
% getTotalAlpha.mode = 1; 1 is LASSO, 2 is Lidge.
function passAlpha = getPassAlphaLR(getTotalAlpha)
exposure = getTotalAlpha.exposure;
alphaName = getTotalAlpha.alphaName;
startTime = getTotalAlpha.startTime ;
stockReturn = getTotalAlpha.stockReturn;
mode = getTotalAlpha.mode;
passNumber = alphaLR(exposure,stockReturn,startTime,mode);

passAlpha.alphaName = alphaName;
passAlpha.matrix = passNumber;
end

%for time loop
function alphaSmallCube = getAlphaTable(exposure,startTime)
[m,n,p] = size(exposure);
alphaSmallCube = exposure(m-startTime +1:m,:,:);
end

% get one alphaTable
function passAlphaNumber = alphaLR(exposure,stockReturn,startTime,mode)
alphaSmallCube = getAlphaTable(exposure,startTime);

for i = 2 : startTime
    everyDayRts = stockReturn(:,i);  % 2 to 100, 1 to 99
    try
        stockReturn;
    catch
        stockReturn = stockReturn';
    end
    
    %stockReturn = stockReturn'; %3842 * 200days
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
        passAlphaNumber(:,i) = coef~=0;
        
    else mode == 2 %Ridge
        disp('the calculation of Ridge is really quick~')
        k = 0.001;
        B = ridge(bigMatrix(:,1),bigMatrix(:,2:end),k);
        %     pic = figure;
        %     plot(B)
        %     hold on
        %     plot(xlim,[0,0],'m--'); %abline y = 0
        %     xlabel('alphaIndex');
        toMask = B(1:size(exposure,3),:) > abs(2e-04);
        passAlphaNumber(i,:) = toMask';
    end
end
end