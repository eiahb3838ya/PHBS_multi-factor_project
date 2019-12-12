function [X, offsetSize] = alpha10(alphaPara, rollingStdWindow, rollingMaxWindow, rollingRankWindow)
%ALPHA10, get alpha10 series from stock struct.
%         formula: RANK(MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5))
%
%INPUTS:  stock: a struct contains stocks' information from exchange,
%includes OHLS, volume, amount etc.
%         rollingStdWindow, rollingMaxWindow: refer to the formula.
%para to uss: stock, rollingStdWindow, rollingMaxWindow, rollingRankWindow

    %set default params
    if nargin == 1
        rollingStdWindow = 20;
        rollingMaxWindow = 5;
        rollingRankWindow = 10;
    end
    
    %     get parameters from alphaPara
    try
        close = alphaPara.close;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(close, rollingStdWindow, rollingMaxWindow, rollingRankWindow);
        return;
    else
        [X, offsetSize] = getAlphaUpdate(close, rollingStdWindow, rollingMaxWindow, rollingRankWindow);
    end
    
end

function [alphaArray, offsetSize] = getAlpha( dailyClose, rollingStdWindow, rollingMaxWindow,rollingRankWindow )
%ALPHA10 formula:RANK(MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5))
%
%INPUT:dailyClose, matrix of size '#days x #companies';
%      default order of ranking vector is incresing order.
%
%OUTPUT: alphaArray -- a matrix, of size '#days x #companies'
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%
%NOTE: data should be cleaned before put into the formula!
%
%Explain on the factor:
%       "(RET < 0) ? STD(RET, 20) : CLOSE"
%       if return < 0: get 20-day rolling std of return
%                else: get close 
%       "MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5)"
%       then squared result from above, get 5-day rolling maximum
%       "RANK(MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5))"
%       then rank the input sequence

    % set default params
    if nargin == 1
        rollingStdWindow = 20; 
        rollingMaxWindow = 5;
        rollingRankWindow = 0;
    end
    
    % get input matrix size and offset size
    [m,n] = size(dailyClose);
    offsetSize = rollingStdWindow;
    
    %--------------------error dealing part start-----------------------
    if sum(isnan(dailyClose))~=0
        error 'nan exists, please check raw data!';
    end
    
    if rollingStdWindow<=rollingMaxWindow
        error 'rolling standard deviation window must be strictly greater than rolling max window size';
    end
    
    if m < rollingStdWindow
        error '#observations must be greater than rolling standard deviation window size(included)';
    end
    
    if rollingRankWindow > m - offsetSize + 1
        error 'rolling rank window size should be smaller than row - offsetSize + 1';
    end
    
    if rollingRankWindow < 0 || rollingStdWindow <=0 || rollingMaxWindow <=0
        error 'rolling rank window should >= 0, other rolling window should > 0!';
    end
    %--------------------error dealing part end-----------------------

    %from daily close to daily return, where the first day row will disappear
    %returnMatrix size: #days - 1 x #companies
    returnMatrix = zeros(m,n);
    returnMatrix(2:end,:) = diff(dailyClose)./dailyClose(1:end-1,:);
    
    %rolling standard deviation matrix, same size as return matrix
    rollingStdMatrix = zeros(m,n);
    
    %get moving standard deviation
    for company = 1:n
        rollingStdMatrix(:,company) = movstd(returnMatrix(:,company),[rollingStdWindow-1,0]);
    end

    %get choiceMatrix, criteria is return<0?STD(RET, 20) : CLOSE; then squared.
    choiceMatrix = returnMatrix < 0;
    toRollingMaxMatrix = choiceMatrix.*rollingStdMatrix + (1-choiceMatrix).*dailyClose;
    toRollingMaxMatrix = toRollingMaxMatrix.*toRollingMaxMatrix;

    %get rolling max
    rollingMaxMatrix = zeros(m,n);
    for company = 1:n
        rollingMaxMatrix(:,company) = movmax(toRollingMaxMatrix(:,company),[rollingMaxWindow-1,0]);
    end

    %get rolling rank matrix
    alphaArray = rollingRank(rollingMaxMatrix, offsetSize,rollingRankWindow);

end

function [alphaArray, offsetSize] = getAlphaUpdate( dailyClose, rollingStdWindow, rollingMaxWindow,rollingRankWindow )
    [X, offsetSize] = getAlpha(dailyClose, rollingStdWindow, rollingMaxWindow,rollingRankWindow );
    alphaArray = X(end,:);
end

% function ansMatrix = rollingRank(rawMatrix,offsetSize, rollingRankWindow)
%     [days,~] = size(rawMatrix);
%     ansMatrix = zeros(size(rawMatrix));
%     
%     if rollingRankWindow == 0
%         disp('alpha10, rolling rank is up to latest date');
%         for day = offsetSize:days
%             rollingSortMatrix= sort(rawMatrix(offsetSize:day,:),1);
%             ansMatrix(day,:) = rollingSortMatrix(end,:);
%         end
%     else
%         disp(['alpha10, rolling rank using window size: ',num2str(rollingRankWindow)]);
%         for day = offsetSize:offsetSize+rollingRankWindow-1
%             rollingSortMatrix= sort(rawMatrix(offsetSize:day,:),1);
%             ansMatrix(day,:) = rollingSortMatrix(end,:);
%         end
%         
%         for day = offsetSize+rollingRankWindow:days
%             rollingSortMatrix= sort(rawMatrix(day-offsetSize+1:day,:),1);
%             ansMatrix(day,:) = rollingSortMatrix(end,:);
%         end
%     end
%     
% end

