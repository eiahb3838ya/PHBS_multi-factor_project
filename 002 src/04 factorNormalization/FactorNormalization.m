classdef FactorNormalization < handle
    properties
        factorCube
        processedFactor
        orthedFactor
    end
    
    
    methods(Static)
        function normFactor = getProcessedFactor(factorCube, saveOption)           
            if nargin == 1
                saveOption = 0;
            end
            
            [m1, m2, m3] = size(factorCube);
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
            
            if saveOption
                save('normFactor', 'normFactor');
                save('meanMatrix', 'meanMatrix');
                save('medianMatrix', 'medianMatrix');
                save('skewnessMatrix', 'skewnessMatrix');
                save('kurtosisMatrix', 'kurtosisMatrix');
            end
        end
        
        
        function orthedFactor = getOrthFactor(factorCube, styleFactorCube, industryFactorCube, saveOption)
            if nargin <= 3
                saveOption = 0;
            end
            
            [l1, m1, n1] = size(factorCube);
            existFactor = cat(3, styleFactorCube, industryFactorCube);
            [l2, m2, n2] = size(existFactor);
            if (l1 ~= l2) || (m1 ~= m2)
                error 'Dimension does not match.'
            end
            
            % regression to get projected Y, with OLS method
            pinvCount = 0;
            orthedFactor = zeros(l1, m1, n1);
            for i = 522: l1
                rawX = reshape(existFactor(i, :, :), m2, n2);
                disp(['processday:', num2str(i)]);
                for j = 1: n1
                    rawY = reshape(factorCube(i, :, j), m1, 1);
                    [nanIndex1, ~] = find(isnan(rawX));
                    nanIndex1 = unique(nanIndex1);
                    nanIndex2 = find(isnan(rawY));
                    [infIndex1, ~] = find(isinf(rawX));
                    infIndex1 = unique(infIndex1);
                    infIndex2 = find(isinf(rawY));
                    nanIndex = unique([nanIndex1; nanIndex2]);
                    infIndex = unique([infIndex1; infIndex2]);
                    omitIndex = unique([nanIndex; infIndex]);
                    nonOmitIndex = setdiff(1:m1, omitIndex)';
                    X = rawX(nonOmitIndex, :);
                    Y = rawY(nonOmitIndex);
                    if length(omitIndex) == m1
                        disp('All stocks have NaN alpha or style factor exposure.')
                        orthedFactor(i, :, j) = NaN * ones(m1, 1);
                        continue
                    end
                    
                    [~, col] = find(sum(abs(X)) ~= 0);
                    X = X(:, unique(col));
                    beta = (X'* X)\(X'* Y); %one way to express inv(X'X)X'Y

                    [~, msgid] = lastwarn(); %catch warning
                    if strcmp(msgid, 'MATLAB:singularMatrix')
                        beta = pinv(X'* X)* X'* Y; % in case conditional number of the matrix is too large
                        pinvCount = pinvCount+1;
                    end
                                       
                    orthRawExposure = zeros(m1, 1);
                    orthRawExposure(nonOmitIndex) = Y - X * beta;
                    orthRawExposure(nanIndex) = NaN;
                    orthRawExposure(infIndex) = inf;
                    orthedFactor(i, :, j) = orthRawExposure;
                    
                end
            end
            disp(['total pinv ', num2str(pinvCount)]);
            
            if saveOption
                save('orthedNormFactor', 'orthedFactor');
            end
        end
    end
    
    
    methods
        function obj = FactorNormalization(factorCube)
            obj.factorCube = factorCube;
        end
        
        function res = calculateNorm(obj)
            try
                obj.processedFactor = obj.getProcessedFactor(obj.factorCube);
                res = 1;
            catch ErrorInfo
                disp(ErrorInfo);  
                disp(ErrorInfo.identifier);  
                disp(ErrorInfo.message);  
                
                res =0;
                return
            end                
        end
        
        
        function res2 = calculateOrth(obj, styleFactorCube, industryFactorCube)
            try
                obj.orthedFactor = obj.getOrthFactor(obj.processedFactor, styleFactorCube, industryFactorCube);
                res2 = 1;
            catch ErrorInfo
                disp(ErrorInfo);  
                disp(ErrorInfo.identifier);  
                disp(ErrorInfo.message);  
                
                res2 =0;
                return
            end
        end
    end
end
