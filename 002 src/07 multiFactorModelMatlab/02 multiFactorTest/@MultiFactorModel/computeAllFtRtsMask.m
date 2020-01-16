function factorRtCube = computeAllFtRtsMask(obj, alphaMaskCube)
%COMPUTEALLFTRTSMASK alphaMaskCube is of D by Alphas by Industry, 0-1 table
    
    % factor rt cube: D by N by Alpha
    totalDays = size(obj.rtMat,1);
    factorRtCube = nan*zeros(totalDays, size(obj.rtMat, 2), size(obj.combinedCube,3) - obj.alphaStartIndex + 1);
    
    % shrink range of data: 
    % row select: one sector
    for sector = 1:size(obj.interceptCube, 3)
        disp(["process sector: ", num2str(sector)]);
        sectorSelectorMat = obj.interceptCube(:,:,sector);
        alphaMaskMat = alphaMaskCube(:,:,sector);
        
        % sector factor return
        sectorFactorReturnMat = nan * ones(totalDays, size(obj.combinedCube,3) - obj.alphaStartIndex + 1);
        
        % for every day, according to alphaMaskCube, do regression
        for currentDay = obj.startIndx + obj.predictionDays : totalDays
            currentDaySectorSelector = sectorSelectorMat(currentDay, :)==1; %row vector
            currentDayAlphaMaskMat = alphaMaskMat(currentDay, :)==1; %row vector, only for alphas
            
            currentDayX_noConst = obj.combinedCube(currentDay, currentDaySectorSelector, currentDayAlphaMaskMat); %1 by stock by alpha
            currentDayY = obj.rtMat(currentDay, currentDaySectorSelector); %1 by stocks
            
            % X,Y to regress
            X = [ones(length(find(currentDaySectorSelector==1)),1),...
                reshape(currentDayX_noConst , [length(find(currentDaySectorSelector==1)), length(find(currentDayAlphaMaskMat==1))])];
            Y = currentDayY(:);
            
            try
                beta = (X'*X)\(X'*Y); %[sector return, factor returns]
            catch ME
                disp(['sector ', num2str(sector), ' day', num2str(currentDay), ' error:', ME.identifier]);
                beta = [];
            end
            
            % go back to a matrix of this sector
            sectorFactorReturnMat(currentDay, currentDayAlphaMaskMat) = beta; 
        end
        factorRtCube(:,:,sector) = sectorFactorReturnMat;
    end
end

