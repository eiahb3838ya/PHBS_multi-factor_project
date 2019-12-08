classdef CleanDataModule
    %CLEANDATAMODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = CleanDataModule(rawDataStruct,cleanParamStruct)
            %CLEANDATAMODULE Construct an instance of this class
            %   input explanation:
            %   RawDataStruct - a struct contains raw data to be cleaned.
            %   
            %   cleanParamStruct - a struct used to record essential
            %   parameters used in clean data. Two sources are allowed, the
            %   first way is independently specified; the other way is to
            %   cast or refer this class by/in a new class, however, no
            %   matter the way you choose, you must have following
            %   structure in a struct to let this function work.
            % structParams -- settingClean01     |-- maxConsecutiveInvalidLength
            %                                    |-- maxConsecutiveRollingSize
            %                                    |-- maxCumulativeInvalidLength     
            %                                    |-- maxCumulativeRollingSize
            %                                    |-- noToleranceRollingSize
            %                                    |-- flag
            %              -- settingRefer01Table|--refStructTableLocation  
            %              -- settingWorkingTable|--refStructTableLocation  
            obj.Property1 = rawDataStruct + cleanParamStruct;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

