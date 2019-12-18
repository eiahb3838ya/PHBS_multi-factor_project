# CleanDataModule Document

``` 
version: 0.3
compatible with: MATLAB R2018a+
```
## current structure
```
@CleanDataModule __ /Methods/majors
                |__ constructor
                |__ getStructToCleanUpdate
                |__ getStructToCleanHistory
                |__ getTradeableStockUpdate
                |__ getTradeableStockHistory
                |__ checkStructAfterSelectionUpdate
                |__ checkStructAfterSelectionHistory
                |__ runUpdate
                |__ runHistory
                
                 __ /Methods/utils
                |__ parseStringToStructPath
                |__ jsonDecoder
                |__ fillDataPlugIns
                |__ getStrcutLastRow
                |__ saveResult
                
                 __ /Methods/getSetPlot
                |__ getResult
                |__ getOHLC
                |__ getStockScreenMatrix
                |__ setRawSTR
                |__ plotNumTradeableStock
                
                 __ /configFiles
                |__ tableNamesToSelect.json
                |__ tradeableStocksSelectionCriteria.json
```
## updates
更新0.3

    预期时间：4pm,Dec.16/2019
    预计更新模块：CleanDataModule
    预计更新时间不晚于Dec.16/2019,4pm
    更新功能：
    - 重新抛出清洗数据warning
    - 抛出每日selection record，存进cleanedData文件夹，记录为selectionRuleResult_YYYYmmdd.mat矩阵
    - 补充额外的util函数，主要红能为实现快速过滤，将selectionRuleResult_YYYYmmdd.mat（必须指定该变量,否则默认为系统当日日期定义的该变量）作为mask作用与所有计算矩阵上，指定mask返回inf，计算时将所有inf使用find(~isinf(row))抛弃(没有加入)
    — 存储数据模块嵌入
    
    

## quick start

example ```./examples```

sample data ```./examples/getDataToUse.txt```

## configuration

```./cleanDataConfig```

### specify who to work with



文件名（constant properties）:
tableNamesToSelect.json

这个文件的作用是指明所有需要被清洗的数据表相对于被引用的结构体的位置，被放入的表格包含两种类型：

类型 I，用于stock screening的数据表，清洗这类表格可以得到每天可以交易的股票池，这类数据表应该是0-1类型的（i.e.指明一个数据点是有效数据点或是无效数据点）。典型的例子是st表，在st表中0代表没有st，1代表出现st，因此0代表数据点有效，1代表数据点无效；而如果是tradeable table，在tradeable table中，0代表数据点是non-tradeable，1代表数据点是tradeable，因此tradeable table中0代表数据点无效，1代表数据点有效。

类型 II，用于计算因子的数据表，清洗这类表格得到用于后续计算的因子值，如果因子值为0，表示不能使用改数据点（根据0-1表得到的约束），如果因子值为nan，代表数据点应该被计算但是值缺损（数据应该存在但没有得到）。

### specify how to work with

文件名（constant properties）: 
tradeableStocksSelectionCriteria.json

文件样式概览：
```
{"settingClean01":{
                    "maxConsecutiveInvalidLength":[0,0],
                    "maxConsecutiveRollingSize":[0,0],
                    "maxCumulativeInvalidLength":[30,30],
                    "maxCumulativeRollingSize":[90,90],
                    "noToleranceRollingSize":[30,30],
                    "flag":0
                    },
    "settingRefer01Table":["stock.tradeDayTable",
                            "stock.stTable"],
    "settingValidIndicator":[1,0]}
```

这个文件的作用是指明如何得到每日的stock screening结果，工作原理是，假设每一个日期都是now，往前回顾updateRows长度的数据（包含now）对应的时间区间，根据json文件中的规则选择出符合规则的股票加入now的可交易股票池。

**此处两个重要的参数**

updateRows: 来源于对所有输入的rolling window取最大值

minUpdateRows: 对noToleranceRollingSize取最小值，在这个区间内，检查数据是否存在nan。理论上，这个区间内，数据不应该存在nan。如果检查到存在nan，返回warning。

**三种规则设定**

最多累计无效数据点量：在每次回顾时间区间中，如果一个股票要在now被认为是可交易的，他所能积累的无效数据点量上限。

最多连续累计无效数据点量：在每次回顾时间区间中，如果一个股票要在now被认为是可交易的，他所能积累的连续无效数据点量上限。

无容忍数据区间长度：在每次回顾的时间区间中，如果一个股票要在now被认为是可交易的，他必须在无容忍数据区间长度中不存在任何无效数据点。


### specify how to fill data

文件名（constant properties）: 
fillDataMathod.json
