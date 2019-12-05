% PLEASE use string('sth') or "sth"
% fillMethod = {[fill head], [fill others]}
LevelOneIndustry = fillData(projectData.stock.sectorClassification,...
    'levelOne', {["nearest"],["mostFrequent"]});

PE = fillData(projectData.stock.properties,...
    'PE_TTM', {["nearest"],["linear"]});