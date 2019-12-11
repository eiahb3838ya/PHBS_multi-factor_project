function [] = runHistory(obj)
%RUNHISTORY this is a pipeline of all history method

obj.getTradeableStockHistory(obj);

disp("check struct data's nan situation: ");
obj.checkStructAfterSelectionHistory(obj);

end

