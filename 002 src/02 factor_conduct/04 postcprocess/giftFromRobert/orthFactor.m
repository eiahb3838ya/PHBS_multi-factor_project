function projectFactor = orthFactor( factor, existingFactorMatrix )
%ORTHFACTOR orthogonalize a column vector against given matrix with same column
%dimension
%           given a column vector Y, size n x 1; a matrix X, size n x k;
%           return the vector Y' after projecting Y onto X.
[m1, ~] = size(factor);
[m2, ~] = size(existingFactorMatrix);
Y = factor;
X = existingFactorMatrix;

% dimension must match
if m1~=m2
    error 'dimension must match!';
end
 
% regression to get projected Y, with OLS method

beta = (X'*X)\(X'*Y); %one way to express inv(X'X)X'Y

[~, msgid] = lastwarn(); %catch warning
if strcmp(msgid,'MATLAB:nearlySingularMatrix')
    beta = pinv(X'*X)*X'*Y; % in case conditional number of the matrix is too large
end

projectFactor = Y - X*beta;
    
end

