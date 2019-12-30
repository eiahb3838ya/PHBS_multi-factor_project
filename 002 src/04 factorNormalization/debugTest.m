a = rand(8, 10);
a = reshape(a, 2, 10, 4);
c = rand(4, 10);
c = reshape(c, 2, 10, 2);
d = rand(4, 10);
d = reshape(d, 2, 10, 2);

b = FactorNormalization(a);
b.calculateNorm();
b.calculateOrth(c, d);