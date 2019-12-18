classdef LayeredBT<handle
    
    properties
        weight = 1;
        startTime = 500;
        endTime = 600;
        numGroup = 5;
        processedAlphas;
        processedClose;
    end
    
    methods
        function obj = singleFactorLayeredBT(startTime,endTime,numGroup,weight)
            obj.startTime = startTime;
            obj.endTime = endTime;
            obj.numGroup = numGroup;
            obj.weight =weight;
        end
        
        function rts = calRts(obj,time)
            close = obj.processedClose.close(time,:);
            closeYesterDay = obj.processedClose.close(time-1,:)
            rts = close ./ closeYesterDay -1;
        end
        
        function portfolioClose = getGroupEqual(obj) %按factor exposure 分组
            for i = obj.startTime: obj.endTime
                result = calRts(obj,i);
                factorExposure = obj.processedAlphas.alpha70(i,:);
                bigMatrix = [result;factorExposure];
                B = bigMatrix';
                B = sortrows(B,2);
                bigMatrix = B';
                [m,n] = size(bigMatrix);
                for j = 1: obj.numGroup
                    group = bigMatrix(:,round(n/obj.numGroup * (j-1) +1) : round(n/obj.numGroup * j));
                    groupStocks{j} = group;
                    portfolioClose(i - obj.startTime + 1 ,j) = mean((groupStocks{j}(:,1)));
                end
            end
        end
        
        function portfolioClose = getGroupMarkerValue(obj) %按factor exposure 分组
            for i = obj.startTime: obj.endTime
                result = calRts(obj,i);
                factorExposure = obj.processedAlphas.alpha043(i,:);
                marketValue = obj.processedAlphas.marketValue(i,:);
                bigMatrix = [result;factorExposure;marketValue];
                B = bigMatrix';
                B = sortrows(B,2);
                bigMatrix = B';
                [m,n] = size(bigMatrix);
                for j = 1: obj.numGroup
                    group = bigMatrix(:,round(n/obj.numGroup * (j-1) +1) : round(n/obj.numGroup * j));
                    groupStocks{j} = group;
                    portfolioClose(i - obj.startTime + 1 ,j) = (groupStocks{j}(:,1) .* ...
                        (groupStocks{j}(:,3))) ./sum((groupStocks{j}(:,3)));
                end
            end
        end
        
        function getNav(obj)
            portfolioClose = getGroupEqual(obj);
            plot(portfolioClose)
            legend('1','2','3','4','5');
            portfolioClose(1,:) = ones(1,obj.numGroup);
            portfolioClose(2:length(portfolioClose),:) = portfolioClose(2:length(portfolioClose),:) +1 ;
            cumPct = cumprod(portfolioClose);
            plot(cumPct);
        end
        
        function [returnYear,volYear,SR,drawdown] = calratio(obj)
            % 年化收益率、波动率、SR ratio、最大回撤
            portfolioClose = getGroupEqual(obj);
            
        end
    end
end
 