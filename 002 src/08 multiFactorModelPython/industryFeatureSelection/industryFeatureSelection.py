#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 16 15:44:51 2020

@author: mac
"""

from scipy import io
from sklearn.linear_model import LinearRegression, Lasso, Ridge
import numpy as np 
import pandas as pd
import matplotlib.pyplot as plt
import h5py
#from collections import deque

#%%
def load():
    ROOT = "."
    #savingROOT = './outputData/'
    #sytleFactorDir = ROOT + "/Data/styleFactor_20200111.mat"
    industryFactorDir = ROOT + "/Data/industryFactor_20200111.mat"
    alphaFactorDir = ROOT + "/Data/NonOrth_orthFactor_20200112.mat"
    returnDir = ROOT + "/Data/returnMatrix.mat"
    stockScreenDir = ROOT + "/Data/stockScreen_20200111.mat"
    
    alphaFactorMat = h5py.File(alphaFactorDir, 'r')
    print(alphaFactorMat.keys())
    alphaFactorCube = np.transpose(alphaFactorMat['exposure'])
    print('alphaFactorCube:', alphaFactorCube.shape)
    
    industryFactorMat = h5py.File(industryFactorDir, 'r')
    print(industryFactorMat.keys())
    industryFactorCube = np.transpose(industryFactorMat['exposure'])
    print('industryFactorCube:', industryFactorCube.shape)
    
    returnMat = io.loadmat(returnDir)
    print(returnMat.keys())
    rts = returnMat['rts']
    print('rts:', rts.shape)
    
    stockScreenMat = h5py.File(stockScreenDir,'r')
    print(stockScreenMat.keys())
    stockScreenTable = np.transpose(stockScreenMat['stockScreenMatrix'])
    print('stockScreenTable:', stockScreenTable.shape)
    return alphaFactorCube, industryFactorCube,rts,stockScreenTable

#%% simple one day
#Simple linear one day 往前移动一天，yt实际是yt+1
def getShiftedReturnTable(rts):
    d_timeShift = -1
    stockReturn = pd.DataFrame(rts)
    shiftedReturnTable = stockReturn.shift(d_timeShift)
    return shiftedReturnTable
    #shiftedReturnTable.tail(10)

def Slice(timeslice,alphaFactorCube,industryFactorTable,stockScreenTable):
    X_alpha = alphaFactorCube[timeslice, :, :]
    X_industry = industryFactorTable[timeslice, :]
    stockScreen = stockScreenTable[timeslice, :]
    return X_alpha,X_industry,stockScreen

def getIndustryModel(shiftedReturnTable,startTime,endTime,alphaFactorCube,industryFactorCube,stockScreenTable):
    modelIC = np.full((shiftedReturnTable.shape[0],industryFactorCube.shape[2]),np.nan)
    lSReturnTable = np.full((shiftedReturnTable.shape[0],industryFactorCube.shape[2]),np.nan)
    summaryfactorReturn = np.full((2166,32,34),np.nan)
    for i in range(industryFactorCube.shape[2]):
        print('This is {} industry'.format(i))
        factorReturnTable = np.zeros((shiftedReturnTable.shape[0], 32))
        X_industryTable = industryFactorCube[:, :, i]
        for timeslice in range(startTime,endTime):
            X_alpha,X_industry,stockScreen = Slice(timeslice,alphaFactorCube,X_industryTable,stockScreenTable)
            y_shiftedReturn = shiftedReturnTable.iloc[timeslice]
            
            X_all = np.concatenate([np.array(X_industry).reshape(-1, 1), X_alpha], axis= 1)
            toMask = np.concatenate([np.array(y_shiftedReturn).reshape(-1, 1), X_all],axis = 1)
            finiteIndex = np.isfinite(toMask).all(axis = 1)
            IstockScreen = np.logical_and(X_industry, stockScreen)
            validIndex = np.logical_and(finiteIndex,  IstockScreen.astype(bool))
            validToCal = toMask[validIndex, :]
            
            if not validIndex.any() :
                continue

            print("is there any inf:", np.isinf(validToCal).any())
            print("is there any nan:",np.isnan(validToCal).any())
            print("validToCal", validToCal.shape)

            X = validToCal[:, 1:]
            y = validToCal[:, 0]
            print("X of ",timeslice , X.shape)
            print("y of ",timeslice,  y.shape)

            model = Lasso(alpha = 0.001, fit_intercept=False)
            model.fit(X, y)

            todayFReturn = model.coef_[-31:]
            todayAlphaIndex = todayFReturn!=0

            # fit model
            todayIndex = np.concatenate([np.ones(1).astype(bool),todayAlphaIndex])
            X_validAlpha = todayIndex * X 
            modelLR = LinearRegression(fit_intercept=False, n_jobs = 5)
            modelLR.fit(X_validAlpha, y)
            
            #debug
            todayValidFReturn = todayIndex * modelLR.coef_
            factorReturnTable[timeslice, :] = todayValidFReturn
            #plot the alpha factor return
            #plt.plot(todayValidFReturn[-31:])

            # predict model
            timeslice = timeslice+1
            X_alpha,X_industry,stockScreen = Slice(timeslice,alphaFactorCube,X_industryTable,stockScreenTable)
            y_shiftedReturn = shiftedReturnTable.loc[timeslice]
            X_all = np.concatenate([np.array(X_industry).reshape(-1, 1), X_alpha], axis= 1)
            print("shape of X:", X_all.shape, "\nshape of y:", y_shiftedReturn.shape)
        
            toMask = np.concatenate([np.array(y_shiftedReturn).reshape(-1, 1), X_all],axis = 1)
            finiteIndex = np.isfinite(toMask).all(axis = 1)
            IstockScreen = np.logical_and(X_industry, stockScreen)
            validIndex = np.logical_and(finiteIndex, IstockScreen.astype(bool))
            validToCal = toMask[validIndex, :]
            
            if not validIndex.any() :
                continue
            
            print("is there any inf:", np.isinf(validToCal).any())
            print("is there any nan:",np.isnan(validToCal).any())
            print("validToCal", validToCal.shape)
            
            X = validToCal[:, 1:]
            y = validToCal[:, 0]
            print("X of ",timeslice , X.shape)
            print("y of ",timeslice,  y.shape)
            
            predictReturn = np.zeros(y.shape[0])
            predictReturn = np.dot(X,todayValidFReturn)
            modelIC[timeslice,i] = np.corrcoef(predictReturn, y)[0,1]
            
            #define long short portfolio return
            lSReturnTable[timeslice,i] = LSPortReturn(predictReturn,y,timeslice,i)
        summaryfactorReturn[:,:,i] = factorReturnTable
    return summaryfactorReturn, modelIC,lSReturnTable

def LSPortReturn(predictReturn,y,timeslice,i):
    print("start construct long short portfolio in timeslice",timeslice,",in industry",i)
    lSOneOneDf = pd.DataFrame({"predict return":predictReturn,
                                     "true return":y})    
    lSOneOneDfSorted = lSOneOneDf.sort_values(by = "predict return",ascending = False)
    lSRatio = 0.1
    
    numLong = round(lSRatio * lSOneOneDfSorted.shape[0])
    numShort = round(lSRatio * lSOneOneDfSorted.shape[0])
    lSIndex = np.zeros(lSOneOneDfSorted.shape[0])
    lSIndex[:numLong] = 1
    lSIndex[-numShort:] = -1
    lSResult = (lSOneOneDfSorted['true return'] * lSIndex).mean(0)
    return lSResult

def plotModelIC(modelIC, industryCount,startTime,endTime):
    print ('hi there, we have {} industrys to plot, hold on'.format(industryCount)) 
    plt.figure(figsize = (20, industryCount//3*8))
    meanModelIC = modelIC[startTime +1 :endTime-2,:].mean(0)
    for i in range(industryCount):
        print('This is {} industry'.format(i))
        # plot modelIC
        if np.isnan(modelIC[startTime +1:endTime-2, i]).all() :
            continue
        plt.subplot(industryCount//3+1, 3, i+1)
        
        plt.plot(modelIC[startTime +1:endTime-2, i],'-o', ms = 3)
        plt.title('IC of industry number:'+str(i)+'\nmean:{}'.format(format(meanModelIC[i],'.6f')))
        plt.hlines(0, 0, endTime - startTime)

def plotOneSectorLSReturn(lSReturnTable,industryCount,startTime,endTime):
    print ('hi there, we have {} industrys sector to plot, hold on'.format(industryCount)) 
    plt.figure(figsize = (20, industryCount//3*8))
    
    for i in range(industryCount):
        print('This is {} industry'.format(i))
        #plot each industry sector LS Portfolio Return
        lSReturnTable = pd.DataFrame(lSReturnTable)
        lSReturnTable = lSReturnTable.dropna(axis=0,how='all')  #删除全nan的行
        OneSectorLSReturn = lSReturnTable.iloc[:, i]+1
        cumOneSectorLSReturn = OneSectorLSReturn.cumprod()
        
        if np.isnan(OneSectorLSReturn).all() :
            continue
        plt.subplot(industryCount//3+1, 3, i+1)
        plt.grid()
        plt.plot(cumOneSectorLSReturn,'-o', ms = 3)
        plt.title('This is {} SectorLSReturn'.format(i)+\
                  '\nstartTime:{}'.format(startTime)+'\nendTime:{}'.format(endTime))
        
def plotLSReturn(lSReturnTable,startTime,endTime):
    plt.figure(figsize = (20, 20))
    lSReturnTable = pd.DataFrame(lSReturnTable)
    lSReturnTable = lSReturnTable.dropna(axis=0,how='all')  #删除全nan的行
    lSReturnTable = lSReturnTable.dropna(axis=1,how='all')  #删除全nan的列
    meanLSReturn = pd.Series(lSReturnTable.mean(axis=1)) + 1
    cumLSReturn = meanLSReturn.cumprod()
    #plt.subplot(industryCount//3+1, 3, i+1)
    plt.grid()
    plt.plot(cumLSReturn,'-o', ms = 3)
    plt.title('cum LS Portfolio Return'+'\nstartTime:{}'.format(startTime)+'\nendTime:{}'.format(endTime))
    
def plotFactorReturn(summaryfactorReturn,industryCount,startTime,endTime):
    print ('hi there, we have {} industrys sector to plot, hold on'.format(industryCount)) 
    for i in range(industryCount):
        sectorTable = summaryfactorReturn[:,:,i]
        alphaCount = summaryfactorReturn.shape[1]
        plt.figure(figsize = (20, alphaCount//3*8))
        for j in range(alphaCount):
            print('This is {} alpha'.format(j))
            plt.subplot(alphaCount//3+1, 3, j+1)
            plt.grid()
            plt.plot(sectorTable[startTime:endTime-1,j],'-o', ms = 3)
            plt.title('This is {} Sector'.format(i)+'{} alpha'.format(j)+\
                  '\nstartTime:{}'.format(startTime)+'\nendTime:{}'.format(endTime))
            
