%按天循环
%每天算29个因子之间的corr,得到 29 * 29 的 Matrix
%1. 计算自变量两两之间的相关系数及其对应的P值，一般认为相关系数>0.7，且P<0.05时可考虑自变量之间存在共线性，可以作为初步判断多重共线性的一种方法。
%2. 共线性诊断统计量，即Tolerance（容忍度）和VIF（方差膨胀因子）。一般认为如果Tolerance<0.2或VIF>5（Tolerance和VIF呈倒数关系），则提示要考虑自变量之间存在多重共线性的问题。
function passNumber = alphaEDA(exposure, alphaName,startTime)
[m,n,p] = size(exposure);

for i = m-startTime +1:m
    matrix = exposure(i,:,:);
    reshapeAlpha = reshape(matrix,[n,p]);
    passAlpha = zeros(n,p);
    reshapeAlpha = rmmissing(reshapeAlpha,1);
    [x,y]=find(reshapeAlpha==inf);
    reshapeAlpha(unique(x),:)=[];
    corrMatrix = corr(reshapeAlpha);
    
    pic = figure(); %'visible','off'
    ezplot('0');
    h = heatmap(alphaName, alphaName, corrMatrix, 'FontSize', 10, 'FontName', 'Consolas');
    h.Title = 'Correlation Coefficients of Orthed Factors';
    colormap(jet);
    saveas(gcf,strcat('correlation_alpha_','_time_',num2str(i),'_',date,'.fig'));

    % calculate VIF matrix
    [~, q] = size(reshapeAlpha);
    VIFVector = zeros(q, 1);
    for j = 1: q
        Y = reshapeAlpha(:, j);
        X = [reshapeAlpha(:, 1: (j - 1)), reshapeAlpha(:, (j + 1): q)];
        rSquare = regstats(Y,X,'linear','rsquare');
        rSquare = rSquare.rsquare;
        VIFVector(j) = 1/(1-rSquare);
    end
    VIFJudge(:,1) = VIFVector<5;
    passNumber(i,:) = VIFJudge';
end
end