function result= alpha_032()
%(-1 * SUM(RANK(CORR(RANK(HIGH), RANK(VOLUME), 3)), 3))
    high=1+rand(80,6) %high
    volume=1+rand(80,6) %volume
    rts=1+rand(80,6) %return
        
    temp=zeros(size(high));
    [m,n]=size(temp);
     numofstock=size(temp,2);
        
     for i=1:length(temp)
        newvolume(i,:)=sort(volume(i,:),1)
        newvolume=sort(newvolume)
     end
     
     for i=1:length(temp)
        newhigh(i,:)=sort(high(i,:),1)
        newhigh=sort(newhigh)
     end
     
      
    
       for i=3:length(temp)
            for j=1:numofstock
                corrmatrix32=corrcoef(newhigh(i-2:i,j),newvolume(i-2:i,j))
                corr32(i,j)=corrmatrix32(1,2)
            end
       end
       
    corr32=sort(corr32)
    
    for i=5:length(temp)
        qiuhe(i,:)=mean(corr32(i-2:i,:))*3
    end
    
    result = qiuhe;
end
     
     