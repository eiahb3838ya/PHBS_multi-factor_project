function [X, offsetSize] = RSTR(stock)
% computed as the sum of log return over the trailing T =500 trading days with a lag of L =21 trading days;
% stock is a structure

% clean data module here

% get factor module here
    [X, offsetSize] = getAlpha(stock.properties.totalReturn);
end

%-------------------------------------------------------------------------
function [exposure, offsetSize] = getAlpha(rt)
    [m,n]= size(rt);
    w = ExponentialWeight(500, 126);
    w = [w ; zeros(21,1)]; %get a large vector, first 500  is exponentialWeight, last 21 is zero.
    wMatrix =  repmat(w,1,n); %rep the w, n times, the ExponentialWeight of each column is the same.
    
    for i = 521:m
        logrts = log(1+rt(i-520:i,:));
        cal = wMatrix .* logrts;
        sum500Days = sumPast(cal,521);
        moment(i,:) = sum500Days(end,:)
    end
    
    exposure = moment;
    offsetSize = 521;
end
    
