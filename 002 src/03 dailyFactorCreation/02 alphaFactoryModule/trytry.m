try 
    Klass = AlphaFactory(projectData, 0, filledCells);
catch
    disp('load data')
    load('projectData.mat');
     Klass = AlphaFactory(projectData, 1, []);
end
    
Klass.saveAllAlphaHistory()

