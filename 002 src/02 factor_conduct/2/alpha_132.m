function result= alpha_132(amount)
    %MEAN(AMOUNT,20)
    amount=1+rand(80,6) %amount
    
    temp=zeros(size(amount));
    [m,n]=size(temp);
    numofstock=size(temp,2);
     
    for i=20:length(temp)
        temp132(i,:)= mean(amount(i-19:i,:))
    end
    result = temp132; 
end