function [alphaArray,offsetSize] = alpha100(volume, rollingWindow)
%ALPHA100 STD(VOLUME,20) 
%   volume,size = #days x #companies
%   OUTPUTS: offsetSize, alphaArray(offsetSize:end,:) are useful data
%   NOTE: data should be cleaned before put into the formula!

if nargin == 1
    rollingWindow = 20;
end

offsetSize = rollingWindow;

[m,n] = size(volume);

if sum(isnan(volume))~=0
    error 'nan exists!please check the data!';
end

if rollingWindow <= 0
    error 'rolling window should be greater than 0(strictly)';
end 

if rollingWindow > m
    error 'rolling window should not be greater than rows of input matrix!';
end

%get rolling standard deviation
rollingStdMatrix = zeros(m,n);
for col = 1:n
    rollingStdMatrix(:,col) = movstd(volume(:,col), [rollingWindow-1,0]);
end

alphaArray = rollingStdMatrix;

end

