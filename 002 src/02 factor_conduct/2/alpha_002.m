function [result]= alpha_002(open,high,low,close)
        high=1+rand(80,6) %high
        low=1+rand(80,6) %low
        open=1+rand(80,6) %open
        close=1+rand(80,6) %close
        amount=1+rand(80,6) %amount
        volume=1+rand(80,6) %volume
        rts=1+rand(80,6)

        temp=zeros(size(high));
        [m,n]=size(temp);
        temp=((close-low)-(high-close))./(high-low);
        
        for i=1:length(temp) %  1-80天
            if i==1
                temp(i,:)=temp(i,:);
            else
                temp(i,:)=temp(i,:)-temp(i-1,:);
            end
        end
        
        for i=1:(length(temp)-1)
    %求解线性方程，求解线性方程组xA = B for x   mrdivide(A, B)
            result(i)=mrdivide(temp(i,:), rts(i+1,:))
            plot(result)
            xlabel('80 Days')
            ylabel('alpha002 factorreturn')
        end
end
