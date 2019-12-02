function [alphaArray, offsetSize] = alpha080(volume, delay)
%ALPHA080 (VOLUME-DELAY(VOLUME,5))/DELAY(VOLUME,5)*100
%INPUT: volume,matrix of size '#days x #companies';;
%
%OUTPUT: alphaArray -- a matrix, of 'size days x #companies'
%
%        offsetSize -- offsetSize, alphaArray(offsetSize:end,:) are useful data
%NOTE: data should be cleaned before put into the formula!

if nargin == 1
    delay = 5;
end

offsetSize = delay;
[m,~] = size(volume);

if sum(isnan(volume))~=0
    error 'nan exists!check the raw data!';
end

if m < offsetSize
    error 'more than 5 days of observation is required!'
end

%get DELAY(VOLUME,5)
delayMatrix = delayMat(volume, delay);

%get VOLUME-DELAY(VOLUME,5)
diffMatrix = volume - delayMatrix;

% diffMatrix/delayMatrix*100
%add epsilon in case of 0 division
alphaArray = 100*diffMatrix ./ (delayMatrix + eps);

end

function delayMatrix = delayMat(rawMatrix, delay)

ansMatrix = zeros(size(rawMatrix));
ansMatrix(delay+1:end,:) = rawMatrix(1:end-delay,:); 

delayMatrix = ansMatrix;
end
