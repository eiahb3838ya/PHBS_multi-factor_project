#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 17 13:03:59 2020

@author: Trista
"""

from industryFeatureSelection import getShiftedReturnTable, getIndustryModel, load,\
plotModelIC,plotLSReturn,plotOneSectorLSReturn,plotFactorReturn

#%% define some static var
START_TIME = 2100
END_TIME = 2166

#%%  load some data
alphaFactorCube, industryFactorCube,rts,stockScreenTable = load()

#%% test my little func
shiftedReturnTable = getShiftedReturnTable(rts)
summaryfactorReturn, modelIC, lSReturnTable = getIndustryModel(shiftedReturnTable,
                                                               startTime = START_TIME, endTime = END_TIME,
                                                               alphaFactorCube = alphaFactorCube,
                                                               industryFactorCube = industryFactorCube,
                                                               stockScreenTable = stockScreenTable)

#%% plotModelIC
industryCount = industryFactorCube.shape[2]
plotModelIC(modelIC, industryCount, START_TIME, END_TIME)

#%% plot LSportfolioReturn
plotLSReturn(lSReturnTable,START_TIME,END_TIME)

#%% plot OneSectorLSportfolioReturn
plotOneSectorLSReturn(lSReturnTable,industryCount,START_TIME,END_TIME)

#%%
plotFactorReturn(summaryfactorReturn,industryCount,START_TIME,END_TIME)
