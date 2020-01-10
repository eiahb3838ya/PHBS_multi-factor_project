classdef AlphaSelection < handle
    
    properties
        %cube
        processedAlphas;
        alphaNameList;
        
        %mat 
        processedClose;
        returnClose;
        
        %public
        startTime;
        selectMode;
        
    end
    
    methods(Static)
        function rts = calRts(processedClose, startTime)
            targetClose = processedClose.close(end-startTime +1:end,:);
            closeYesterday = processedClose.close(end-startTime:end-1,:);
            rts = targetClose ./ closeYesterday -1;
        end
    end
    
    methods
        
        %一张表
        
        %for time 循环
        
    end
end