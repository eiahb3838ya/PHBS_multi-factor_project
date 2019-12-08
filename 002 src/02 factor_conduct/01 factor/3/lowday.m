function lowDay = lowday(A, k)
% LOWDAY(A, n) is the time interval between the min of the previous n and
% the current time

    [m, n] = size(A);
    lowDay = zeros(m, n);
    for i = 1: k - 1
        [~, index] = min(A(1: i, :));
        lowDay(i, :) = i - index;
    end
    for i = k: m
        [~, index] = min(A(i - k + 1: i, :));
        lowDay(i, :) = i - index;
    end
end