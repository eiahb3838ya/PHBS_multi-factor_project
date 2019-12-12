function ansMatrix = rollingRank(rawMatrix,offsetSize,rollingRankWindow)
%rollingRank: get rolling rank of a matrix, size = '#days x #companies';
%           Params: rollingRankWindow = 0: no fixed window size, rolling
%           up to latest date
%                   rollingRankWindow = otherNumber: fixed window size

    [days,~] = size(rawMatrix);
    ansMatrix = zeros(size(rawMatrix));
    
    if rollingRankWindow == 0
        disp('rolling rank is up to latest date');
        for day = offsetSize:days
            rollingSortMatrix= sort(rawMatrix(offsetSize:day,:),1);
            ansMatrix(day,:) = rollingSortMatrix(end,:);
        end
    else
        disp(['rolling rank using window size: ',num2str(rollingRankWindow)]);
        for day = offsetSize:offsetSize+rollingRankWindow-1
            rollingSortMatrix= sort(rawMatrix(offsetSize:day,:),1);
            ansMatrix(day,:) = rollingSortMatrix(end,:);
        end
        
        for day = offsetSize+rollingRankWindow:days
            rollingSortMatrix= sort(rawMatrix(day-offsetSize+1:day,:),1);
            ansMatrix(day,:) = rollingSortMatrix(end,:);
        end
    end
    
end

