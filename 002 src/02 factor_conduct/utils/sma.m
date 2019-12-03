function Y = sma(A, n, m)
%sma: compute SMA of a matrix, size = '#days x #companies'
    
    Y = zeros(size(A));
    
    for i=1:size(Y,1)
        if i==1
            Y(i,:) = A(i,:);
        else
            Y(i,:) = (A(i-1,:)*m + Y(i-1,:)*(n-m))/n;
        end
    end
end

