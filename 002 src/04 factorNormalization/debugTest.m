a = rand(8, 10);
a = reshape(a, 2, 10, 4);

b = FactorNormalization(a);
b.calculateNorm();