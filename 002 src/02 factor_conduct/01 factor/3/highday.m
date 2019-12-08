function highDay = highday(A, k)
% HIGHDAY(A, n) is the time interval between the max of the previous n and
% the current time

    [m, n] = size(A);
    highDay = zeros(m, n);
    for i = 1: k - 1
        [~, index] = max(A(1: i, :));
        highDay(i, :) = i - index;
    end
    for i = k: m
        [~, index] = max(A(i - k + 1: i, :));
        highDay(i, :) = i - index;
    end
end