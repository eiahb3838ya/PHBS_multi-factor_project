function resultStruct = summarySingleFactorTest(day,rollingWindow,fkthrehold,ICmode,ICthrehold,ICmode,d,S)
     resultStruct = struct();
     fNs=fieldnames(S);
     
    for count=1:length(fNs)
    %check field size first, avoid illegal input
     alphaName = fNs{count};
     alpha = S.(fNs{count});
     X = singleFactorTest(alpha,day,rollingWindow,ICmode,d,S,alphaName)
     resultStruct.(fNs{count}) = X;
    end
end