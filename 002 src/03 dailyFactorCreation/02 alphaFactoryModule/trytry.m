try 
    Klass = AlphaFactory(projectData,'testParamStruct.json', cleanedData);
catch
    disp('load data')
    load('projectData.mat');
    Klass = AlphaFactory(projectData);
end
    


