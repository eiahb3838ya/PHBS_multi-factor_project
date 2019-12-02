function [alphaArray, offsetSize] = alpha010( dailyClose, omitInvalidCalculation )
%ALPHA10 formula:RANK(MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5))
%INPUT:dailyClose, matrix of size 'days x #companies';
%
%      default order of ranking vector is incresing order.
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies'
%
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%NOTE: data should be cleaned before put into the formula!
%Explain on the factor:
%       "(RET < 0) ? STD(RET, 20) : CLOSE"
%       if return < 0: get 20-day rolling std of return
%                else: get close 
%       "MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5)"
%       then squared result from above, get 5-day rolling maximum
%       "RANK(MAX(((RET < 0) ? STD(RET, 20) : CLOSE)^2),5))"
%       then rank the input sequence

[m,n] = size(dailyClose);

if m<=25
    error '#observations must be greater than 25(exclude)';
end

%from daily close to daily return, where the first day row will disappear
%returnMatrix size: days - 1 x #companies
returnMatrix = diff(dailyClose)./dailyClose(1:end-1,:);

rollingStd20Matrix = zeros(m-1,n);
%get moving standard deviation, where the first 20 element is not rolling20
%std.
for company = 1:n
    rollingStd20Matrix(:,company) = movstd(returnMatrix(:,company),[19,0]);
end

%get squared close price matrix
closeSquaredMatrix = dailyClose(2:end,:).*dailyClose(2:end,:);

%get choiceMatrix, criteria is return<0?then squared.
judgeMatrix = returnMatrix < 0;
choiceMatrix = judgeMatrix.*rollingStd20Matrix + (1-judgeMatrix).*closeSquaredMatrix;
choiceMatrix = choiceMatrix.*choiceMatrix;

%get rolling max, period = 5,where the first 5 element is not rolling5 max
maxMatrix = zeros(m-1,n);
for company = 1:n
    maxMatrix(:,company) = movmax(choiceMatrix(:,company),[4,0]);
end

%get rank matrix
alphaArray = zeros(size(dailyClose));
alphaArray(2:end,:) = sort(maxMatrix,1);


offsetSize = 25;
end

