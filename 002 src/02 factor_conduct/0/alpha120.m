function [alphaArray,offsetSize] = alpha120(vwap, dailyClose)
%ALPHA120 RANK(VWAP - CLOSE) / RANK(VWAP + CLOSE)
%   INPUTS: vwap - volume weighted average price, size = #days x #companies
%           dailyClose - close price, size = #days x #companies
%   OUTPUTS: offsetSize, alphaArray(offsetSize:end,:) are useful data
%   NOTE: data should be cleaned before put into the formula!
offsetSize = 1;

[m1, n1] = size(vwap);
[m2, n2] = size(dailyClose);

if sum(isnan([volume,vwap]))~=0
    error 'nan exists!please check the data!';
end

if ~(m1 == m2 && n1 == n2)
    error 'vwap and dailyClose should have the same size.';
end

minusMatrix = vwap - dailyClose;
plusMatrix = vwap - dailyClose;

alphaArray = sort(minusMatrix,1)./sort(plusMatrix,1);

end

