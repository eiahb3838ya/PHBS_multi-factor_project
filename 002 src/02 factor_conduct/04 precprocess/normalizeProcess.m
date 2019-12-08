function normalizedTable = normalizeProcess(feedStruct, fieldName)
% NORMALIZEPROCESS returns the normalized version of feedStruct with
% z-score method 
% The normalization will be cross-sectional, which means row-wise
% x_i = (x_i - mean(x_i))/std(x_i)
% check validity of input: fieldName
    if isfield(feedStruct, fieldName) == 0
        error 'field name not contained in the given structure';
    end
    normalizedTable = feedStruct.(fieldName);
    normalizedTable = zscore(normalizedTable, 0, 2);
    [m, ~] = size(normalizedTable);
    plot(normalizedTable(m, :));
end