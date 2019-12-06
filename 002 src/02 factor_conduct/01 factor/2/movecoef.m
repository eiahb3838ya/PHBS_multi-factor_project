function calmovecoef = movecoef(A,B,k)
    [m,n] = size(A);
        for i=k:m
            for j=1:n
                corrmatrix=corrcoef(A(i-k+1:i,j),B(i-k+1:i,j));
                corr(i,j)=corrmatrix(1,2);
            end
        end
     calmovecoef = corr;
end

        
       