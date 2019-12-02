function []= alpha_042(close,high,low)
        %((-1 * RANK(STD(HIGH, 10))) * CORR(HIGH, VOLUME, 10))
        high=1+rand(80,6) %high
        low=1+rand(80,6) %low
        open=1+rand(80,6) %open
        close=1+rand(80,6) %close
        amount=1+rand(80,6) %amount
        volume=1+rand(80,6) %volume
        rts=1+rand(80,6)
        
        temp=zeros(size(high));
        [m,n]=size(temp);
        
        stdhigh=zeros(size(high))
        stdhigh(1:9,:)=high(1:9,:)
        
        for i=10:length(temp)
          stdhigh(i,:)=std(high(i-9:i,:))
        end
       
        %sort 按行从小到大排序，并乘 -1
        temp1=-1 * sort(stdhigh,2)
        
        numofstock=size(temp,2)
        for i=10:length(temp)
            for j=1:numofstock
                corrmatrix=corrcoef(high(i-9:i,j),volume(i-9:i,j))
                corr(i,j)=corrmatrix(1,2)
            end
        end
        
        temp=temp1.*corr
        
        for i=10:(length(temp)-1)
    %求解线性方程，求解线性方程组xA = B for x   mrdivide(A, B)
            result(i)=mrdivide(temp(i,:), rts(i+1,:))
            plot(result)
            xlabel('10-79 Days')
            ylabel('alpha042 factorreturn')
        end
end