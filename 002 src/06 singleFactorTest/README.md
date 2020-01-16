SingleFactorLayeredBackTest

1. 选取一个基准组合(沪深300) 或者是 所有分层组合中个股的合并
2. 将每个股票按照某个alphaxxx，从小到大进行排序，分成n组（n=5 or 10），没有做行业中性组合，一般来说对于比较有效的因子，分成3-5层进行回测，各个投资组合的最终净值可以保序。
3. 每个组合中的股票 等权配比 or 按流通市值配比
4. 每天计算factor exposure，第二天调仓（or 每2天调仓）
5. 评价方法：回测年化收益率、波动率、SR ratio、最大回撤


SingleFactorTest readme

需要在目录下新建存放ICplot的文件夹和testResult的文件夹。

- 改变singleAlphaTest Class里的存放路径

第21行，第106行，第149行需要改路径。

cd('/Users/mac/Desktop/test/singleFactorReturn_ICplot'); 存放IC图片

cd(’/Users/mac/Desktop/test/singleFactorReturn_testResult‘);存放统计检验的mat

------

-  main function

summarySingleFactorTest(day,rollingWindow,ICmode,d,S)

需要输入：

day是哪一天回测，比如1600

rollingWindow是回测的窗口是多少长，比如600，

ICmode，ICmode  = 1 NormalIC ；ICmode=0 rankIC

d是IC预测多少天，1 or 2

S是输入的struct，这个struct必须包含一列close，close表的大小和factor exposure的表大小要一样。

![image-20191214171644126](/Users/mac/Library/Application Support/typora-user-images/image-20191214171644126.png)

```
load('processedAlphas')；
a.summarySingleFactorTest(1600,600,0,2,processedAlphas)；
```

a.summarySingleFactorTest是所有因子的统计结果，会调用

```
function result = singleFactorTest(alpha,day,rollingWindow,ICmode,d,alphaPara,fNs)
function sumS = sumsummary(S)
```

------

singleFactorTest(alpha,day,rollingWindow,ICmode,d,alphaPara,fNs)

alpha是单个因子比如alpha011，day是1600，rollingWindow=600，ICmode=1 or 0，d=2 IC预测的天数，alphaPara是输入的结构体，fNs是结构体中因子的Name。

会调用

```
  function IC = ICValue(alpha,day,rollingWindow,d,alphaPara)
  function IC = rankICValue(alpha,day,rollingWindow,d,alphaPara)
  function signaficance = absMeanTest(m,numBootstrp)
  function stationarity = ADFTest(m)
  function summary = singleFactorTest(alpha,day,rollingWindow,ICmode,d,alphaPara,fNs)
```
