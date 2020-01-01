function [corrMatrix, VIFVector] = EDA(orthFactor, alphaName)
% EDA receives the orthogonalized factor exposure of a day and calculates 
% the correlation and VIF vector of factors, it also saves the
% matrix, vector and the heatmap.
% orthFactor is a matrix with its row as stocks and columns as factors.
    
    % calculate the correlation matrix
    corrMatrix = corr(orthFactor);
    
    % draw the heatmap of correlation coefficients
    h = heatmap(alphaName, alphaName, corrMatrix, 'FontSize', 10, 'FontName', 'Consolas');
    h.Title = 'Correlation Coefficients of Orthed Factors';
    colormap(jet)
    saveas(gcf, sprintf('corrHeatmap.jpg'), 'bmp');
    
    % calculate VIF matrix
    [~, n] = size(orthFactor);
    VIFVector = zeros(n, 1);
    for i = 1: n
        Y = orthFactor(:, i);
        X = [orthFactor(:, 1: (i - 1)), orthFactor(:, (i + 1): n)];
        beta = (X' * X) \ (X' * Y);
        YHat = X * beta - mean(Y);
        rSquare = YHat'* YHat / ((Y - mean(Y))' * (Y - mean(Y)));
        VIFVector(i) = 1 / (1 - rSquare);
    end
end
    
    