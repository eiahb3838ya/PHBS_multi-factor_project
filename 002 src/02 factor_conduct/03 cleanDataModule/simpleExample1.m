% VERY IMPORTANT:
% When running the script, please check the projectData is in your matlab working path
% otherwise clarify your own data in constructor by its name(string), if you would like
% to test your own data, must modify .json file!

CDM = CleanDataModule();
CDM.runHistory();
resultS = CDM.getResult();
