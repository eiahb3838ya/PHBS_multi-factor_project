% try 
%     Klass = AlphaFactory(projectData,'testParamStruct.json');
%     
% catch
%     disp('load data')
%     load('projectData.mat');
%     Klass = AlphaFactory(projectData);
% end

% style factor
Klass = AlphaFactory(projectData,'styleParamStruct.json');
Klass.cleanedData.indexTotalReturn = projectData.index.totalReturn(:,7);
    


