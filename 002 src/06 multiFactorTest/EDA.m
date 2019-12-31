function [corrMatrix, VIFMatrix] = EDA(orthFactor, alphaName)
% EDA receives the orthogonalized factor exposure of a day and calculates 
% the correlation and VIF coefficient matrix of factors, it also saves the
% matices and the heatmaps.
% orthFactor is a matrix with its row as stocks and columns as factors.
    
    % calculate the correlation matrix
    corrMatrix = corr(orthFactor, orthFactor);
    
    % draw the heatmap of correlation coefficients
    h = heatmap(alphaName, alphaName, corrMatrix, 'FontSize', 10, 'FontName', 'Consolas');
    h.Title = 'Correlation Coefficients of Orthed Factors';
    colormap(jet)
    saveas(gcf, sprintf('corrHeatmap.jpg'), 'bmp');
    
    % calculate VIF matrix
    
    % draw the heatmap of VIFs
end
    
    