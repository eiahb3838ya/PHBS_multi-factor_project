function sumPast = sumPast(A, n)
    sumPast = zeros(size(A));
    for i = 1:n
        toAdd = [zeros(i, size(A, 2));A(1:end-i,:)];
        sumPast = sumPast + toAdd;
    end
end
