function [] = runUpdate(obj)
%RUNUPDATE this is a pipeline of all update method

obj.getTradeableStockUpdate(obj);

disp("check struct data's nan situation: ");
obj.checkStructAfterSelectionUpdate(obj);

end

