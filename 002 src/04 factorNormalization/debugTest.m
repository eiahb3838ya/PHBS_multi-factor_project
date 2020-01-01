a = rand(8, 10);
a = reshape(a, 2, 10, 4);
for i = 1: 4
    mat = reshape(a(:, :, i), 2, 10);
    row = unidrnd(2);
    col = unidrnd(10);
    mat(row, col) = NaN;
    a(:, :, i) = mat;
end

c = rand(4, 10);
c = reshape(c, 2, 10, 2);
for i = 1: 2
    mat = reshape(c(:, :, i), 2, 10);
    row = unidrnd(2);
    col = unidrnd(10);
    mat(row, col) = NaN;
    c(:, :, i) = mat;
end

d = rand(4, 10);
d = reshape(d, 2, 10, 2);

b = FactorNormalization(a);
b.calculateNorm();
b.calculateOrth(c, d);