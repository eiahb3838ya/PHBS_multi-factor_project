function visualization(factorExposureCell, stockReturnCell)
% function visualization(factorExposureCell, stockReturnCell, alphaFilter)
% VISUALIZATION receives the factor exposures and stock returns for every
%   factor in every industry sector of the day, give out plots of the
%   ladder-like returns with exposures for every sector of the day.
% factorExposureCell is a cell of matrices (stocks x factors), cell
%   index is sectors.
% stockReturnCell is a cell of vectors (stocks), cell index is
%   sectors.
% alphaFilter is a vector (factors) that indicates what alpha factors 
%   should be implemented of the day.
    sectorLen = length(factorExposureCell);
    for i = 1: sectorLen
        [~, stocks, factors] = size(factorExposureCell{i});
        factorExposure = factorExposureCell{i};
        factorExposure = reshape(factorExposure, stocks, factors);
            for k = 1: factors
                % to eliminate the factors that cannot be used today
                kFactorExposure = factorExposure(:, k);
                % kFactorExposure(~alphaFilter) = 0;
                if ~all(kFactorExposure)
                    disp(['No. ', num2str(k), ' alpha factor cannot be used today.'])
                    continue
                end
                % to rank the exposures from the biggest to the smallest
                [rankedExposure, rankIndex] = sort(kFactorExposure, 'descend');
                % rankedExposure = num2str(rankedExposure');
                stockReturn = stockReturnCell{i};
                % reorder stock returns according to the order of the
                % exposure
                stockReturn = stockReturn(rankIndex);
                
                % draw the horizontal bars, with x-axis as stock returns
                % and y-axis as exposures
                figure(i)
                subplot(2, 1, k)
                barh(stockReturn, 0.8, 'c')
                rankedCharExposure = cell(1, factors);
                for j = 1: factors
                    rankedCharExposure{j} = num2str(rankedExposure(j));
                end
                set(gca, 'yTickLabel', rankedCharExposure)
                ylabel('factor exposure')
                xlabel('stock return')
                
                % draw the line chart, with x-axis as exposures and y-axis
                % as stock returns
                figure(sectorLen + i)
                subplot(2, 1, k)
                plot(rankedExposure, stockReturn)
            end
    end
end 