%SMA(VOLUME,21,2)
%SMA(A, n, m) 


volume = projectData.stock.properties.volume;
alpha = sma(volume, 21, 2);


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



        
        


