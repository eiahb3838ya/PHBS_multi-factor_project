function []= alpha_062(high,volume)
%(-1 * CORR(HIGH, RANK(VOLUME), 5))
%这个volume排序的时候我觉得有点问题...
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
            
        for i=5:length(temp)
            for j=1:numofstock
                corrmatrix=corrcoef(high(i-4:i,j),newvolume(i-4:i,j))
                corr1(i,j)=corrmatrix(1,2)
            end
        end
        
        alpha062= -1 *corr1;
end

        
        
