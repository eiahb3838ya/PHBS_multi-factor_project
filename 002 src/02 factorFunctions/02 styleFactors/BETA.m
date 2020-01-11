function [X, offsetSize] = BETA(alphaPara)
% Returns the log value of the total market capital of single stocks
% log(total market capital)
% min data size: 1
% alphaPara is a structure
    try
        Close = alphaPara.close;
        indexReturn = alphaPara.indexTotalReturn;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end

% calculate and return all history factor
% controled by updateFlag, call getAlpha if TRUE
    if ~updateFlag
        [X, offsetSize] = getBETA(Close,indexReturn);
        return
    else
        [X, offsetSize] = getBETAUpdate(Close,indexReturn);
    end
end

%-------------------------------------------------------------------------
function rts = calRts(Close)
[~,n] = size(Close);
closeYesterday = [zeros(1,n);Close(1:end-1,:)];
rts = Close ./ closeYesterday -1;
end
        
function [beta, offsetSize] = getBETA(Close,indexReturn)
warning('off')
% function compute factor exposure of style factor
rts = calRts(Close);
[m,n] = size(Close);
w = ExponentialWeight(250, 60);
%beta = zeros(m,n);

for i = 251:m %days
    disp(strcat('start process day :', int2str(i)));
    sliceRts = rts(i-250+1:i,:);
    sliceIndexReturn = indexReturn(i-250+1:i);
    sliceRts = w.*sliceRts;
    sliceIndexReturn = w.*sliceIndexReturn;
%     if i==267
%         disp('haha')
%     end
    for j =1:n %stocks
        BigMatrix = [sliceRts(:,j),sliceIndexReturn];
        
        BigMatrix = rmmissing(BigMatrix,1);
        [infRow,~] = find(isinf(BigMatrix));
        BigMatrix(infRow, :) = [];
        thisBeta = regress(BigMatrix(:,2),BigMatrix(:,1));
        
        beta(i,j) = thisBeta;
    end
end
offsetSize = 252;
end

function [beta, offsetSize] = getBETAUpdate(Close,indexReturn)
    % function compute factor exposure of style factor
    rts = calRts(Close);
    w = ExponentialWeight(250, 60);
    [m, n] = size(Close);
    sliceRts = rts(m-250+1:m,:);
    sliceIndexReturn = indexReturn(m-250+1:m);
    sliceRts = w.*sliceRts;
    sliceIndexReturn = w.*sliceIndexReturn;
    
    for j =1:n %stocks
        BigMatrix = [sliceRts(:,j),sliceIndexReturn];

        BigMatrix = rmmissing(BigMatrix,1);
        [infRow,~] = find(isinf(BigMatrix));
        BigMatrix(infRow, :) = [];
        thisBeta = regress(BigMatrix(:,2),BigMatrix(:,1));

        beta(m,j) = thisBeta;
    end
    offsetSize = 252;
end