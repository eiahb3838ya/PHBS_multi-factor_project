function processedFactor = factorNormalization(factorCube)
% FACTORNORMALIZATION returns the normalized factor loadings after their
% extreme values being processed
% factorCube is the raw 3 dimensional factor loadings matrix, with one
% dimension of dates, one dimension of factors and the last dimension of
% stocks, namely m1, m2, m3 respectively.
        [m1, m2, ~] = size(factorCube);
        processedFactor = factorCube;
        meanMatrix = zeros(m1, m2);
        medianMatrix = zeros(m1, m2);
        skewnessMatrix = zeros(m1, m2);
        kurtosisMatrix = zeros(m1, m2);
        for i = 1: m1
            processedFactor(i, :, :) = extremeProcess(processedFactor(i, :, :));
            [processedFactor(i, :, :), meanMatrix(i, :), medianMatrix(i, :), skewnessMatrix(i, :), kurtosisMatrix(i, :)] ...
                = normalizeProcess(processedFactor(i, :, :), i); 
        end
        save('normFactor', processedFactor);
        save('meanMatrix', meanMatrix);
        save('medianMatrix', medianMatrix);
        save('skewnessMatrix', skewnessMatrix);
        save('kurtosisMatrix', kurtosisMatrix);
end