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
                %    prepare for incremental
                try
                    matobj = matfile(fileName,'Writable',true);
                    matobj.(exposureName) = cat(1,matobj.(exposureName),exposure);
                    out = 1;
                    return
                catch
                    out = 0;
                    return
                end
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

        function alpha = getAlphaIncrement(obj, alphaName)
            %           check valid
            aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 1);
            alpha = obj.getAlpha(alphaName, aPara);
        end

        function alpha = getAlphaHistory(obj, alphaName)
            %           check valid
            aPara = obj.getAlphaPara(obj.paraStruct.(alphaName), 0);
            alpha = obj.getAlpha(alphaName, aPara);
        end

        function success = saveAlphaHistory(obj, alphaName)
            exposure = obj.getAlphaHistory(alphaName);
            success = obj.saveAlpha(exposure, alphaName, alphaName, 0);
        end
        
        function success = saveAlphaIncrement(obj, alphaName)
            exposure = obj.getAlphaIncrement(alphaName);
            success = obj.saveAlpha(exposure, alphaName, alphaName, 1);
        end
            
        function saveAllAlphaIncrement(obj, oldVersionDate, saveStucture)
            if nargin<3
                saveStucture = 0;
            end
            targetAlphas = fieldnames(obj.paraStruct);
            
            %    get the old alphaCube with oldVersoin date
            oldfileName = strcat('factorExposure_', oldVersionDate);
            oldmatobj = matfile(oldfileName, 'Writable', true);
            rowCount = size(oldmatobj.(targetAlphas{1}), 1);
            disp(strcat('the size of old exposure is:',string(rowCount)));
            
            %    create a new version with today date
            fileName = strcat('factorExposure_', datestr(now, 'yyyymmdd'));
            matobj = matfile(fileName, 'Writable', true);
            
            %    save as struct
            if saveStucture
                for k=1:length(targetAlphas)
                    alphaName=targetAlphas{k};
                    disp("start process:"+ alphaName);
                    try
                        exposure = obj.getAlphaIncrement(alphaName);
                        matobj.(alphaName) = cat(1, oldmatobj.(alphaName),exposure);
                        disp("success")
                    catch
                        disp("fail")
                    end
                end
                rowCount = size(matobj.(targetAlphas{1}), 1);
                disp(strcat('the size of old exposure is:',string(rowCount)));
                
            %    save as 3 dim mat
            else
                %   get old exposure
                oldExposure = oldmatobj.('exposure');
                oldAlphaNameList = oldmatobj.('alphaNameList');
                
                %   new exposure to append
                exposure = [];
                alphaNameList = [];
                
                %    iter through all targetAlphas and app
                for k=1:length(targetAlphas)
                    alphaName=targetAlphas{k};
                    disp("start process:"+ alphaName);
                    try
                        exposure = cat(3,exposure,obj.getAlphaIncrement(alphaName));
                        alphaNameList = [alphaNameList, alphaName];
                        disp("success")
                    catch
                        disp("fail")
                    end
                end
                
                %    check new alphaname order
                %    append to old exposure
                newExposure = cat(1,oldExposure,exposure);
                
                %    save to new file
                matobj.('exposure') = newExposure;
                matobj.('alphaNameList') = alphaNameList;
                rowCount = size(matobj.exposure, 1);
                disp(strcat('the size of new exposure is:',string(rowCount)));
            end
        end

        function saveAllAlphaHistory(obj, saveStucture)
            if nargin<2
                saveStucture = 0;
            end
            targetAlphas = fieldnames(obj.paraStruct);
            fileName = strcat('factorExposure_', datestr(now, 'yyyymmdd'));
            matobj = matfile(fileName, 'Writable', true);
            
            if saveStucture
            %    save as struct
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
            %    save as 3 dim mat
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