function sumPast = sumPast(A, n)
    sumPast = zeros(size(A));
    for i = 1:n
        ii = i-1;
        toAdd = [zeros(ii, size(A, 2));A(1:end-ii,:)];
        sumPast = sumPast + toAdd;
    end
end
