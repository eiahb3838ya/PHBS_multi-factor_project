classdef factorNormalization < handle
    properties
        factorCube
        processedFactor
    end
    
    methods(Static)
        function processedFactor = getProcessedFactor(factorCube)           
            [m1, ~, m3] = size(factorCube);
            meanMatrix = zeros(m1, m3);
            medianMatrix = zeros(m1, m3);
            skewnessMatrix = zeros(m1, m3);
            kurtosisMatrix = zeros(m1, m3);
            extremeFactor = zeros(m1, m2, m3);
            normFactor =zeros(m1, m2, m3);
            for i = 1: m3
                extremeFactor(:, :, i) = extremeProcess(reshape(factorCube(:, :, i), m1, m2));
                [normFactor(:, :, i), meanMatrix(:, i), medianMatrix(:, i), skewnessMatrix(:, i), kurtosisMatrix(:, i)] ...
                    = normalizeProcess(reshape(extremeFactor(:, :, i), m1, m2), i); 
            end
            
            processedFactor = normFactor;
            save('normFactor', processedFactor);
            save('meanMatrix', meanMatrix);
            save('medianMatrix', medianMatrix);
            save('skewnessMatrix', skewnessMatrix);
            save('kurtosisMatrix', kurtosisMatrix);
        end
        
        function orthedFactor = getOrthFactor(factorCube, styleFactorCube, industryFactorCube)
            [l1, m1, n1] = size(factorCube);
            existFactor = cat(3, styleFactorCube, industryFactorCube);
            [l2, m2, n2] = size(existFactor);
            if (l1 ~= l2) || (m1 ~= m2)
                error 'Dimension does not match.'
            end
            
            % regression to get projected Y, with OLS method
            orthedFactor = zeros(l1, m1, n1);
            for i = 1: l1
                X = reshape(existFactor(i, :, :), n2, m2);
                for j = 1: n1
                    Y = reshape(factorCube(i, :, j), m1, 1);
                    beta = (X'* X)\(X'* Y); %one way to express inv(X'X)X'Y

                    [~, msgid] = lastwarn(); %catch warning
                    if strcmp(msgid, 'MATLAB:nearlySingularMatrix')
                        beta = pinv(X'* X)* X'* Y; % in case conditional number of the matrix is too large
                    end
                    orthedFactor(i, :, j) = Y - X * beta;
                end
            end
            save('orthedNormFactor', orthedFactor);
        end
    end
    
    methods
        function obj = factorNormalization(factorCube)
            obj.factorCube = factorCube;
        end
        
        function res = calculateNorm(obj)
%             processedFactor = getProcessedFactor(obj.rawData);
            try
                obj.processedFactor = getProcessedFactor(obj.factorCube);
                res = 1;
            catch
                res =0;
                return
            end                
        end
        
        function res2 = calculateOrth(obj, styleFactorCube, industryFactorCube)
            try
                obj.orthedFactor = getOrthFactor(obj.processedFactor, styleFactorCube, industryFactorCube);
                res2 = 1;
            catch
                res2 = 0;
                return
            end
        end
    end
end