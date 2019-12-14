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
        
        function out = getVarName(var)
            out = inputname(1);
        end
        
        function cleanedData = getCleanedData(rawData)
         
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
        function obj = AlphaFactory(rawData, cleanDataPlz, cleanedData, paraJsonDir)
            obj.rawData = rawData;
            
            %    default paraJsonDir is "testParamStruct.json"
            if nargin>3
                obj.paraJsonDir = paraJsonDir;
            else
                obj.paraJsonDir = "testParamStruct.json";
            end
                 
            %    load json to struct and show result
            disp('loadJson start')
            if obj.loadJson()
                disp('loadJson success')
            else
                disp('loadJson fail')
            end
            
            %    clean data from rawdata
            if cleanDataPlz
                obj.cleanedData = obj.getCleanedData(obj.rawData);
            else
                obj.cleanedData = cleanedData;
            end
        end
       
        function res = loadJson(obj)
            
            %             use static method to load json and store in property paraStruct
            obj.paraStruct = obj.testJsonDecoder(obj.paraJsonDir);
            res = isstruct(obj.paraStruct);
            return
        end
      
        function alphaPara = getAlphaPara(obj, aStruct, incrementalFlag)
            requireData = aStruct.datasets;
            
            %             iter through all require datasets
            %             put it in alphaPara
            for k=1:length(requireData)
                setName=requireData{k};
                alphaPara.(setName) = obj.cleanedData.(setName);
            end
            alphaPara.updateFlag = incrementalFlag;          
        end

%         function alpha = getAlphaUpdate(obj, alphaName)
%             %           check valid
%             aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 1);
%             alpha = obj.getAlpha(alphaName, aPara);
%         end

        function alpha = getAlphaHistory(obj, alphaName)
            %           check valid
            aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 0);
            alpha = obj.getAlpha(alphaName, aPara);
        end
 
        function out = saveAlpha(obj, exposure, exposureName, fileName, incrementalFlag)
            if ~incrementalFlag
                try
                    matobj = matfile(fileName,'Writable',true);
                    matobj.(exposureName) = exposure;
                    out = 1;
                    return
                catch
                    out = 0;
                    return
                end
            else
                %    prepare for update: not yet ready

%                 toSaveString = inputname(2);
%                 m = matfile(fileName,'Writable',true);
%                 m.(toSaveString) = exposure;
            end
        end
        
        function success = saveAlphaHistory(obj, alphaName)
            exposure = obj.getAlphaHistory(alphaName);
            success = obj.saveAlpha(exposure, alphaName, alphaName, 0);
        end
            

%         function updateAllAlpha(obj, folderDir, timeSlide)
%         end

        function saveAllAlphaHistory(obj, saveStucture)
            
            if nargin<2
                saveStucture = 0;
            end
            
            targetAlphas = fieldnames(obj.paraStruct);
            fileName = strcat('factorExposure_', datestr(now, 'yyyymmdd'));
            matobj = matfile(fileName, 'Writable', true);
            
            if saveStucture
                %                 save as struct
                for k=1:length(targetAlphas)
                    alphaName=targetAlphas{k};
                    disp("start process:"+ alphaName);
                    try
                        exposure = obj.getAlphaHistory(alphaName);
                        matobj.(alphaName) = exposure;
                        disp("success")
                    catch
                        disp("fail")
                    end
                end
            else
            %                 save as 3 dim mat
                exposure = [];
                alphaNameList = [];
                for k=1:length(targetAlphas)
                    alphaName=targetAlphas{k};
                    disp("start process:"+ alphaName);
                    try
                        exposure = cat(3,exposure,obj.getAlphaHistory(alphaName));
                        alphaNameList = [alphaNameList, alphaName];
                        disp("success")
                    catch
                        disp("fail")
                    end
                end
                matobj.('exposure') = exposure;
                matobj.('alphaNameList') = alphaNameList;
            end
        end 
        
    end
end