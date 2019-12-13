function orthFactor = orthProcess(factor, existFactorMatrix)
%ORTHPROCESS orthogonalize a column vector against given matrix with same column
%dimension
%           given a column vector Y, size n x 1; a matrix X, size n x k;
%           return the vector Y' after projecting Y onto X.
    [row1, ~] = size(factor);
    [row2, ~] = size(existFactorMatrix);
    Y = factor;
    X = existFactorMatrix;

    % dimension must match
    if row1 ~= row2
        error 'dimension must match!';
    end
 
    % regression to get projected Y, with OLS method

    beta = (X'* X)\(X'* Y); %one way to express inv(X'X)X'Y

    [~, msgid] = lastwarn(); %catch warning
    if strcmp(msgid, 'MATLAB:nearlySingularMatrix')
        beta = pinv(X'* X)* X'* Y; % in case conditional number of the matrix is too large
    end

    orthFactor = Y - X * beta;
    
end