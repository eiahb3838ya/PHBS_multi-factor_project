# -*- coding: utf-8 -*-
"""
Created on Wed Jan  8 14:52:26 2020

@author: Evan
"""
#%%
from MultiFactorModelTest import MultiFactorModelTest
from scipy import io
import numpy as np 
import pandas as pd
import matplotlib.pyplot as plt
import h5py

#%%

ROOT = "."
savingROOT = './outputData/'

#%%
sytleFactorDir = ROOT + "/bigDataProjectData/02 styleFactor/02 styleFactor/styleFactor_20200111.mat"
industryFactorDir = ROOT + "/bigDataProjectData/02 styleFactor/01 industryFactor/industryFactor_20200111.mat"
alphaFactorDir = ROOT + "/bigDataProjectData/04 factorNormalization/NonOrth_orthFactor_20200112.mat"
closeDir = ROOT + "/bigDataProjectData/closeStock.mat"
stockScreenDir = ROOT + "/bigDataProjectData/stockScreen_20200109.mat"

# mat = io.loadmat('yourfile.mat')
#alphaFactorMat = io.loadmat(alphaFactorDir)
#print(alphaFactorMat.keys())
#alphaFactorCube = alphaFactorMat['orthFactorCube']
#print('alphaFactorCube:', alphaFactorCube.shape)
#%%
alphaFactorMat = h5py.File(alphaFactorDir, 'r')
print(alphaFactorMat.keys())
alphaFactorCube = np.transpose(alphaFactorMat['exposure'])
print('alphaFactorCube:', alphaFactorCube.shape)

#%%
sytleFactorMat = h5py.File(sytleFactorDir, 'r')
print(sytleFactorMat.keys())
sytleFactorCube = np.transpose(sytleFactorMat['exposure'])
print('sytleFactorCube:', sytleFactorCube.shape)
#%%
industryFactorMat = h5py.File(industryFactorDir, 'r')
print(industryFactorMat.keys())
industryFactorCube = np.transpose(industryFactorMat['exposure'])
print('industryFactorCube:', industryFactorCube.shape)

#%%
closeMat = io.loadmat(closeDir)
print(closeMat.keys())
close = closeMat['close']
print('close:', close.shape)

#%%
stockScreenMat = io.loadmat(stockScreenDir)
print(stockScreenMat.keys())
stockScreenTable = stockScreenMat['stockScreenMatrix']
print('stockScreenTable:', stockScreenTable.shape)
#%%
Klass = MultiFactorModelTest(close, 
                             industryFactorCube, 
                             sytleFactorCube, 
                             alphaFactorCube, 
                             stockScreenTable, 
                             d_timeShift = 1 )

modelIC, predictReturnTable, factorReturnTable, validFactorTable = Klass.singleFactorTest(0, noStyle=True, doPlot=True, backTestDays =1465, T = 1)
#%%
modelICs, predictReturnTables, factorReturnTables = Klass.singleFactorTestAll(noStyle = True, doPlot=True, backTestDays=200, T = 1, saveDir=savingROOT)
#%%
modelIC, predictReturnTable, factorReturnTable, validFactorTable = Klass.multiFactorTest(noStyle=True,doPlot=True, backTestDays =200, T = 1, useRidge = False)
#%%
plt.figure(figsize = (20, 8))
plt.plot(modelIC[-1465+1:-1])
pd.Series(modelIC[-1465+1:]).to_csv(savingROOT+"normalIC.csv")

#%%
















