callVars = ["close","high","open","low","amount","volume"];
filledCells = fillDataV2(projectData.stock.properties, callVars,{["constant",0],["linear"]});
