classdef BasicClass < handle
    
    properties 
        paraJsonDir
        paraStruct
        cleanedData      
        stock
    end
    
    methods(Static)
        function outStruct= testJsonDecoder(fname)
            %JSONDECODER Summary of this function goes here
            %   Detailed explanation goes here
            fid = fopen(fname); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid); 
            outStruct = jsondecode(str);
        end
        
        function cleanedData = getCleanedData(stock)
%             先隨便寫一個到時候用你的
            cleanedData.high = stock.properties.high;
            cleanedData.close = stock.properties.close;
            cleanedData.low = stock.properties.low;
            cleanedData.open = stock.properties.open;
            cleanedData.volume = stock.properties.open;
        end
        
        function alpha = getAlpha(alphaName, alphaPara)
            disp(alphaName);
            if isstruct(alphaPara)
                alpha = feval(alphaName, alphaPara);
            end
        end
            
    end
    methods
        function obj = BasicClass(paraJsonDir, stock)
            obj.stock = stock;
            
            if isstring(paraJsonDir)
                obj.paraJsonDir = paraJsonDir
            else
                obj.paraJsonDir = "testParamStruct.json"
            end
            disp('loadJson start')
                        
%             load json to struct and show result
            if loadJson(obj)
                disp('loadJson success')
            else
                disp('loadJson fail')
            end
            obj.cleanedData = obj.getCleanedData(obj.stock)
        end
       
        function res = loadJson(obj)
%             use static method to load json and store in property paraStruct
            obj.paraStruct = obj.testJsonDecoder(obj.paraJsonDir);
            res = isstruct(obj.paraStruct);
            return
        end
      
        function alphaPara = getAlphaPara(obj, aStruct, updateFlag)
            requireData = aStruct.datasets;
            
%             iter through all require datasets
%             put it in alphaPara
            for k=1:length(requireData)
                setName=requireData{k};
                disp(setName);
                alphaPara.(setName) = obj.cleanedData.(setName);
            end
            alphaPara.updateFlag = updateFlag;
                        
        end

        function alpha = getAlphaUpdate(obj, alphaName)
%           check valid
            aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 1);
            alpha = obj.getAlpha(alphaName, aPara);
        end

%         function getAlphaHistory(obj, alphaName)
%         end
% 
%         function saveAlpha(obj, toSave, fileDir, updateFlag)
%         end
% 
%         function updateAllAlpha(obj, folderDir, timeSlide)
%         end
% 
%         function historyAllAlpha(obj, folderDir, timeSlide)
%         end  
      end
end