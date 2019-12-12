function sumS = sumsummary(S)
fNs=fieldnames(S);
sumS=0;
for count=1:length(fNs)
%check field size first, avoid illegal input
     sumS=sumS+sum(sum(S.(fNs{count})));
end
end