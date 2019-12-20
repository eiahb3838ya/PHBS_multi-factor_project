a = rand(8, 10);
a = reshape(a, 2, 10, 4);
b = rand(2, 10);
for i = 1: 4
    mat = reshape(a(:, :, i), 2, 10);
    row = unidrnd(2);
    col = unidrnd(10);
    mat(row, col) = NaN;
    a(:, :, i) = mat;
end
c = grouping(a, b);