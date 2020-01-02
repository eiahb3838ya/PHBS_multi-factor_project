function w = ExponentialWeight(T, halflife)
t = (1:T)';
w = flipud(exp(-log(2)/halflife*t));
end