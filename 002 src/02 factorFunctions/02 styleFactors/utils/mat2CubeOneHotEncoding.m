function cube = mat2CubeOneHotEncoding(mat, fillNan)
%MAT2CUBEONEHOTENCODING convert matrix(2d) to a cube(3d) via one-hot
%encoding
%   given any matrix, potential element should contains no nans, otherwise
%   init fillNan = 1 to fill with nearest element; otherwise, throw
%   error.

    % check if nans in the matrix
    if nargin == 1
        fillNan = 1;
        disp('if nan, fill with columnwise nearest element!');
    end
    
    if ~fillNan
        if sum(sum(mat))~=0
            error('must init with fillNan method, because nan exists');
        end
    end
    
    % clean nan if there is any
    if sum(sum(isnan(mat)))~=0
        [~,nanCols] = find(isnan(mat));
        for col = unique(nanCols)
            mat(:,col) = fillmissing(mat(:,col),'nearest');
        end
        
        % in case all nan in a column
        if sum(sum(isnan(mat)))~=0
            mat = fillmissing(mat,'constant',0);
        end
    end
    
    % get unique values
    uniqueInMat = unique(mat);
    
    % prepare empty cube
    cube = zeros([size(mat),length(uniqueInMat)]);
    
    % loop over and do one-hot encoding
    for indx = 1:length(uniqueInMat)
        cube(:,:,indx) = mat == uniqueInMat(indx);
    end

end

