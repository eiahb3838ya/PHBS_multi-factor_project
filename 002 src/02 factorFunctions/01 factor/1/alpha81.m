
function [X, offsetSize] = alpha81(alphaPara)
    %alpha81 SMA(VOLUME,21,2)
    %SMA(A, n, m) is in sma.m
    %input the whole history matrix all the time, no matter update or not
    try
        volume = alphaPara.volume;
        updateFlag  = alphaPara.updateFlag;
    catch
        error 'para error';
    end
    
    %     calculate and return all history factor
    %     controled by updateFlag, call getAlpha if TRUE 
    if ~updateFlag
        [X, offsetSize] = getAlpha(volume);
        return
        
    %     return only latest factor
    else
        [X, offsetSize] = getAlphaUpdate(volume);
    end
    
end

function [exposure, offsetSize] = getAlpha(volume)
    exposure = sma(volume, 21, 2);
    offsetSize = 1;
end

function [exposure, offsetSize] = getAlphaUpdate(volume)
    exposure = sma(volume, 21, 2);
    offsetSize = 1;
end



% sma
% A = volume;
% n = 21
% m = 2
% 
% Y = zeros(size(A));
% for i=1:size(Y,1)
%     if i==1
%         Y(i,:) = A(i,:);
%     else
%         
%         Y(i,:) = (A(i-1,:)*m + Y(i-1,:)*(n-m))/n;
%     end
% end



        
        


