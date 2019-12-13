processedAlphas = struct();
load('alpha003.mat')
processedAlphas.alpha003 = exposure;
load('alpha11.mat')
processedAlphas.alpha11 = exposure;
load('alpha31.mat')
processedAlphas.alpha31 = exposure;
load('alpha043.mat')
processedAlphas.alpha043 = exposure;
load('alpha053.mat')
processedAlphas.alpha053 = exposure;
load('alpha063.mat')
processedAlphas.alpha063 = exposure;
load('alpha093.mat')
processedAlphas.alpha093 = exposure;
load('alpha103.mat')
processedAlphas.alpha103 = exposure;
load('alpha133.mat')
processedAlphas.alpha133 = exposure;
load('alpha153.mat')
processedAlphas.alpha153 = exposure;
load('alpha189.mat')
processedAlphas.alpha189 = exposure;


paraStruct = struct();
paraStruct.n = 3;
paraStruct.choice = "median";
processedAlphas.alpha003 = extremeProcess(processedAlphas.alpha003, paraStruct);
processedAlphas.alpha11 = extremeProcess(processedAlphas.alpha11, paraStruct);
processedAlphas.alpha31 = extremeProcess(processedAlphas.alpha31, paraStruct);
processedAlphas.alpha043 = extremeProcess(processedAlphas.alpha043, paraStruct);
processedAlphas.alpha053 = extremeProcess(processedAlphas.alpha053, paraStruct);
processedAlphas.alpha063 = extremeProcess(processedAlphas.alpha063, paraStruct);
processedAlphas.alpha093 = extremeProcess(processedAlphas.alpha093, paraStruct);
processedAlphas.alpha103 = extremeProcess(processedAlphas.alpha103, paraStruct);
processedAlphas.alpha133 = extremeProcess(processedAlphas.alpha133, paraStruct);
processedAlphas.alpha153 = extremeProcess(processedAlphas.alpha153, paraStruct);
processedAlphas.alpha189 = extremeProcess(processedAlphas.alpha189, paraStruct);


processedAlphas.alpha003 = normalizeProcess(processedAlphas.alpha003);
processedAlphas.alpha11 = normalizeProcess(processedAlphas.alpha11);
processedAlphas.alpha31 = normalizeProcess(processedAlphas.alpha31);
processedAlphas.alpha043 = normalizeProcess(processedAlphas.alpha043);
processedAlphas.alpha053 = normalizeProcess(processedAlphas.alpha053);
processedAlphas.alpha063 = normalizeProcess(processedAlphas.alpha063);
processedAlphas.alpha093 = normalizeProcess(processedAlphas.alpha093);
processedAlphas.alpha103 = normalizeProcess(processedAlphas.alpha103);
processedAlphas.alpha133 = normalizeProcess(processedAlphas.alpha133);
processedAlphas.alpha153 = normalizeProcess(processedAlphas.alpha153);
processedAlphas.alpha189 = normalizeProcess(processedAlphas.alpha189);