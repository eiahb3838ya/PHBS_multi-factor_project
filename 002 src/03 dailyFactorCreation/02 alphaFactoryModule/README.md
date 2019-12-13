1. breif

2. usage workflow
2. properties
  - paraJsonDir
  等待解析的 json 文檔位置
  - paraStruct
  解析完畢的 parameter structure，一個大結構內有各個因子所用的參數
  - cleanedData 
  清洗完畢的資料，一個 struct 
  - rawData
  清洗前的資料，結構如 projectData
2. methods 
Static
  - function outStruct= testJsonDecoder(fname)
    - 從 fname 讀取 json 文檔，解析成一個結構，回傳
  - function cleanedData = getCleanedData(rawData)
    - 呼叫 CleanDataModule 類，從 rawData 清洗資料，回傳
  - function alpha = getAlpha(alphaName, alphaPara)
    - 用 alphaPara 作為參數呼叫以 alphaName 為名的因子函數
  - function out = saveAlpha(obj, exposure, fileName, updateFlag)
    - save exposure to .mat format with fileName
    - set updateFlag to 1 if append to the last row
Non-Static
  - function obj = AlphaFactory(rawData, paraJsonDir)
    - assign rawData，paraJsonDir 
    - load json to struct and show result
    - clean data from rawData 
    obj.cleanedData = obj.getCleanedData(obj.rawData);
  - function res = loadJson(obj)
    - use static method to load json and store in property paraStruct
  - function alphaPara = getAlphaPara(obj, aStruct, updateFlag)
    - iter through all require datasets
    - put it in alphaPara
    - add a updateFlag 
  - function alpha = getAlphaHistory(obj, alphaName)
    - get alphaPara with Flag 0
    - call getAlpha
  - function success = saveAlphaHistory(obj, alphaName)
    - call getAlphaHistory with alphaName
    - save it with saveAlpha
  - function saveAllAlphaHistory(obj)
    - get all alphaNames in paraStruct
    - iter all names with saveAlphaHistory
    - return successful
            
