classdef singleFactortest < handle
    properties
        %private
        %cube
        processedAlphas;
        
        %mat
        processedClose;
        returnClose;
        factorReturn;
        
        %public
        startTime;
        ICpredictDays;
        ICmode;
    end
    
    methods(Static)
        function rts = calRts(processedClose, starttime)
            targetClose = processedClose.close(end-starttime +1:end,:);
            closeYesterday = processedClose.close(end-starttime:end-1,:);
            rts = targetClose ./ closeYesterday -1;
        end
    end
    
    methods
        function obj = singleFactortest(processedAlphas, processedClose, startTime,ICpredictDays,ICmode)
            %constructor
            obj.processedAlphas = processedAlphas;
            obj.processedClose = processedClose;
            
            if nargin >2
                obj.startTime = startTime;
            else
                obj.startTime = 500;
            end
            
            if nargin >3
                obj.ICpredictDays = ICpredictDays;
            else
                obj.ICpredictDays = 1;
            end
            
            if nargin >4
                obj.ICmode = ICmode;
            else
                obj.ICmode = 1;
            end
            
            obj.returnClose = obj.calRts(obj.processedClose, obj.startTime);
            disp("cal return close")
        end
        
        %calculate the IC for singleFactor
        function IC = ICValue(obj,alphaTable,ICpredictDays,ICmode)
            getAlpha = alphaTable(end-obj.startTime +1:end,:);
            
            %Normal IC:IC mode ==0
            if obj.ICmode == 0
                for i =  1: obj.startTime - obj.ICpredictDays
                    BigMatrix = [getAlpha(i,:);obj.returnClose(i + obj.ICpredictDays,:)]
                    BigMatrix = rmmissing(BigMatrix,2);
                    corrMatrix = corrcoef(BigMatrix(1,:),BigMatrix(2,:));
                    IC(i) = corrMatrix(1,2);
                end
                
                %rank IC:IC mode ==1
            else obj.ICmode == 1
                for i =  1: obj.startTime - obj.ICpredictDays
                    BigMatrix = [getAlpha(i,:);obj.returnClose(i + obj.ICpredictDays,:)]
                    BigMatrix = rmmissing(BigMatrix,2);
                    [~,Alpharank] = sort(BigMatrix(1,:));
                    [~,Returnrank] = sort(BigMatrix(2,:));
                    corrMatrix = corrcoef(Alpharank,Returnrank);
                    IC(i) = corrMatrix(1,2);
                end
            end
            disp("cal IC")
        end
        
        %Calculate AllFactor(number = m) IC and the result is a ICTable (m * starttime)
        function ICTable = calAllFactorIC(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                ICTable(j,:) = ICValue(obj,obj.processedAlphas(:,:,j),obj.ICpredictDays,obj.ICmode)
            end
        end
        
        function plotIC(obj,ICpredictDays,ICmode)
            ICTable = calAllFactorIC(obj);
            [~,~,alphaCount] = size(obj.processedAlphas);
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                IC = ICTable(i,:)
                plot(movmean(IC,5));
                xlabel('startTime');
                
                if obj.ICmode ==0
                    ylabel('NormalICValue');
                    title('NormalIC plot');
                    
                else obj.ICmode == 1
                    ylabel('rankICValue');
                    title('rankIC plot');
                end
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_ICplot');
                savefig(pic, strcat('singleFactorPlot_',num2str(i),'_ICmode=',num2str(obj.ICmode),'_',dt,'.fig'));
                cd(filepath);
            end
        end
        
        %cumFactorReturnPlot
        function factorReturn = calFactorReturn(obj,alphaTable)
            getAlpha = alphaTable(end-obj.startTime +1:end,:);
            [m,~] = size(getAlpha);     
            for i = 1:m-1
                BigMatrix = [getAlpha(i,:);obj.returnClose(i+1,:)];
                BigMatrix = rmmissing(BigMatrix,2);
                factorReturn(i) = regress((BigMatrix(2,:))',(BigMatrix(1,:))');
            end
            disp("cal factor Return")
        end
        
        function cumFactorReturn = calCumFactorReturn(obj,alphaTable)
            factorReturn = calFactorReturn(obj,alphaTable);
            cumFactorReturn = cumprod(factorReturn + 1) /(1+factorReturn(1));
        end
        
        function cumFactorReturnTable = calAllCumFactorReturn(obj)
            [~,~,alphaCount] = size(obj.processedAlphas);
            for j = 1: alphaCount
                cumFactorReturnTable(j,:) = calCumFactorReturn(obj,obj.processedAlphas(:,:,j));
            end
        end
        
        function plotAllCumFactorReturn(obj)
            cumFactorReturnTable = calAllCumFactorReturn(obj);
            [~,~,alphaCount] = size(obj.processedAlphas);
            
            for i = 1: alphaCount
                pic = figure(); %'visible','off'
                cumFactorReturn = cumFactorReturnTable(i,:);
                plot(cumFactorReturn);
                xlabel('startTime');
                ylabel('Factor cumprod returns');
                title('cumFactorReturnPlot');
                
                %save fig
                dt = datestr(now,'yyyymmdd');
                filepath = pwd;
                cd('/Users/mac/Documents/local_PHBS_multi-factor_project/002 src/05 singleFactorTest/singleFactorReturn_cumFactorReturnPlot');
                savefig(pic, strcat('singleFactorReturn_cumFactorReturnPlot_',num2str(i),'_',dt,'.fig'));
                cd(filepath);
            end
            
        end
    end
end