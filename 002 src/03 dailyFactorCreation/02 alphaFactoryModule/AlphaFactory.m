classdef AlphaFactory < handle
    
    properties 
        paraJsonDir
        paraStruct
        cleanedData      
        rawData
    end
    
    methods(Static)
        function outStruct= testJsonDecoder(fname)
            %    JSONDECODER Summary of this function goes here
            %    Detailed explanation goes here
            fid = fopen(fname); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid); 
            outStruct = jsondecode(str);
        end
        
        function cleanedData = getCleanedData(rawData)
            %             先隨便寫一個到時候用你的
%             cleanedData.high = stock.high;
%             cleanedData.close = stock.close;
%             cleanedData.low = stock.low;
%             cleanedData.open = stock.open;
%             cleanedData.volume = stock.volume;
            CDM = CleanDataModule(rawData);
            CDM.runHistory();
            cleanedData = CDM.getResult();

        end
        
        function alpha = getAlpha(alphaName, alphaPara)
            
            if isstruct(alphaPara)
                alpha = feval(alphaName, alphaPara);
            end
        end
            
    end
    methods
        function obj = BasicClass(paraJsonDir, rawData)
            obj.rawData = rawData;
            
            if isstring(paraJsonDir)
                obj.paraJsonDir = paraJsonDir;
            else
                obj.paraJsonDir = "testParamStruct.json";
            end
            disp('loadJson start')
                        
            %             load json to struct and show result
            if obj.loadJson()
                disp('loadJson success')
            else
                disp('loadJson fail')
            end
            %    clean data from 
            
            obj.cleanedData = obj.getCleanedData(obj.rawData);
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
                alphaPara.(setName) = obj.cleanedData.(setName);
            end
            alphaPara.updateFlag = updateFlag;          
        end

        function alpha = getAlphaUpdate(obj, alphaName)
            %           check valid
            aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 1);
            alpha = obj.getAlpha(alphaName, aPara);
        end

        function alpha = getAlphaHistory(obj, alphaName)
            %           check valid
            aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 0);
            alpha = obj.getAlpha(alphaName, aPara);
        end
 
        function out = saveAlpha(obj, exposure, fileName, updateFlag)
            if ~updateFlag
                try
                    save(fileName, "exposure")
                    out = 1;
                    return
                catch
                    out = 0
                    return
                end
            else
                %    update
                %    not yet ready

%                 toSaveString = inputname(2);
%                 m = matfile(fileName,'Writable',true);
%                 m.(toSaveString) = exposure;
            end
        end
        
        function success = saveHistoryAlpha(obj, alphaName)
            exposure = obj.getAlphaHistory(alphaName);
            success = obj.saveAlpha(exposure, alphaName, 0);
        end
            

%         function updateAllAlpha(obj, folderDir, timeSlide)
%         end
% 
        function historyAllAlpha(obj)
            targetAlphas = fieldnames(obj.paraStruct)
            for k=1:length(targetAlphas)
                alphaName=targetAlphas{k};
                disp("start process:"+ alphaName);
                if obj.saveHistoryAlpha(alphaName)
                    disp("success")
                else
                    disp("fail")
                end
            end
        end 
    end
end