% function [X, offsetSize] = RSTR(stock)
% % computed as the sum of log return over the trailing T =500 trading days with a lag of L =21 trading days;
% % stock is a structure
% 
% % clean data module here
% 
% % get factor module here
%     [X, offsetSize] = getAlpha(stock.properties.totalReturn);
% end
% 
% %-------------------------------------------------------------------------
% function [exposure, offsetSize] = getAlpha(rt)
%     [m,n]= size(rt);
%     w = ExponentialWeight(500, 126);
%     w = [w ; zeros(21,1)]; %get a large vector, first 500  is exponentialWeight, last 21 is zero.
%     wMatrix =  repmat(w,1,n); %rep the w, n times, the ExponentialWeight of each column is the same.
%     
%     for i = 521:m
%         logrts = log(1+rt(i-520:i,:));
%         cal = wMatrix .* logrts;
%         sum500Days = sumPast(cal,521);
%         moment(i,:) = sum500Days(end,:)
%     end
%     
%     exposure = moment;
%     offsetSize = 521;
% end

function [X, offsetSize] = RSTR(alphaPara)
% Returns the historical EP,which is the net revenue of the past 12 months 
% of single stocks divided by their current market capital, 
% earnings_ttm / mkt_freeshares
% min data size: 1
% alphaPara is a structure
    try
        totalReturn = alphaPara.totalReturn;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getRSTR(totalReturn);
        return
    else
        [X, offsetSize] = getRSTRUpdate(totalReturn);
    end
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getRSTR(rt)
% function compute factor exposure of style factor
    [m,n]= size(rt);
    w = ExponentialWeight(500, 126);
    w = [w ; zeros(21,1)]; %get a large vector, first 500  is exponentialWeight, last 21 is zero.
    %wMatrix =  repmat(w,1,n); %rep the w, n times, the ExponentialWeight of each column is the same.
    moment = zeros(m, n);
    for i = 521:m
        disp(strcat('start process day :', int2str(i)));
        tic
        logrts = log(1+rt(i-520:i,:));
        cal = w .* logrts;
        toSum = cal(end-520:end, :);
%         sum500Days = sumPast(cal,521);
        toAppend = sum(toSum, 1);
        if i==800
            disp('gift from amy <3')
        end
        moment(i,:) = toAppend;
        toc
    end
    
    exposure = moment;
    offsetSize = 521;
end

function [exposure, offsetSize] = getRSTRUpdate(rt)
    [X, offsetSize] = getRSTR(rt);
     exposure = X(end,:);
end
    
