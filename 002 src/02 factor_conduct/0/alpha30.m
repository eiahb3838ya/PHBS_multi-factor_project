function [X, offsetSize] = alpha30(stock)
%ALPHA030 WMA((REGRESI(CLOSE/DELAY(CLOSE)-1,MKT,SMB,HML, 60))^2,20) 
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.

    %step 1:  get alphas
    [X, offsetSize] = getAlpha(stock.close, stock.MKT, stock.SMB, stock.HML);
end

function [alphaArray,offsetSize] = getAlpha(dailyClose,MKT,SMB,HML)
%ALPHA030 WMA((REGRESI(CLOSE/DELAY(CLOSE)-1,MKT,SMB,HML, 60))^2,20) 
%INPUT:dailyClose, matrix of size 'days x #companies';
%      MKT,SMB,HML, Fama-French 3-factor model, each of size 'days x #companies'
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies'
%
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%NOTE: data should be cleaned before put into the formula!
    offsetSize = 80;
    [m1,n1] = size(dailyClose);
    [m2,n2] = size(MKT);
    [m3,n3] = size(SMB);
    [m4,n4] = size(HML);

    %--------------------error dealing part start-----------------------
    if ~(m1==m2 && m2==m3 && m3==m4 && n1==n2 && n2==n3 && n3==n4)
        error 'Incorrect input size, all inputs should have same size!';
    end

    if m1 < 81
        error 'input should have at least 81(included) observations!'
    end
    %--------------------error dealing part end-----------------------

    %from daily close to daily return, where the first day row will disappear
    %returnMatrix size: days - 1 x #companies
    returnMatrix = diff(dailyClose)./dailyClose(1:end-1,:);

    %delete one row in MKT,SMB,HML to make size match
    MKT(1,:) = [];
    SMB(1,:) = [];
    HML(1,:) = [];

    % do rolling window regression, return_t = b0 + b1*MKT + b2*SMB + b3*HML + e
    % the window size = 60, means for every 60 rows, size = 60*#companies
    % do following steps:
    % X = diag(blockDay1, blockDay2, blockDay3)
    % where blockDay1 = [co1_MKT_D1,..,co1_HML_D1;co2_MKT_D1,...]
    % Y = columnVector([co1_retD1, co2_retD1,...coN_retD1,co1_retD2..,coN_ret60])
    % Y = XB + E
    % E is of residual of size (#company*60) x 1
    windowSize = 60;
    bigMatrix = cat(3,MKT,SMB,HML);%concat a 3-D matrix
    errorMatrix = zeros(m1-windowSize,n1);
    for windowController = 1:m1-windowSize
        %get raw data for rolling regression
        dataY = returnMatrix(windowController:windowController+windowSize-1,:);
        dataX = bigMatrix(windowController:windowController+windowSize-1,:,:);
        
        %reshape data
        %dataY = #days * #companies
        Y = reshape(dataY',[],1); %dataY' = #companies * #days, note reshape is along row-direction
        %dataX = #days * #companies * #factors(=3)
        transposeDataX = permute(dataX,[2,1,3]); %transposeDataX = #companies*#days*#factors(=3)
        tempX = mat2cell(transposeDataX, n1, ones(1,60),3); %slice 3-d matrix into size #companies*1*#factors(=3)

        X_4Darray = cat(4,tempX{:}); %create a 4-d matrix
        X_3Darray = reshape(X_4Darray,[],3,60); %X3 of size #companies*#factors(=3)*#days
        X_2Dcell = mat2cell(X_3Darray, n1, 3, ones(1,60)); %each cell of size #companies*#factors
        X = blkdiag(X_2Dcell{:}); % diagnalized

        % get error term for one-time regression
        E = Y - X*((X'*X)\X'*Y); % E is of size (#companies*60)x1,but only the last row will be used
        reshapeE = reshape(E,[],60); % reshape E to be #companies x #days

        errorMatrix(windowController,:) = reshapeE(:,end);
    end

    %squared them
    errorMatrix = errorMatrix.*errorMatrix;

    %WMA step
    weights = repmat(flip(cumprod(ones(20,1)*0.9)),1,n1); %weight matrix of size 20x#companies
    wmaMatrix = zeros(m1-windowSize-19,n1);
    for row = 20:m1-windowSize
        tempMatrix = errorMatrix(row-19:row,:).*weights;
        wmaMatrix(row-19,:) = sum(tempMatrix,1);
    end

    alphaArray = zeros(m1,n1);
    alphaArray(offsetSize:end,:) = wmaMatrix;

end

