function [] = runHistory(obj, warningSwitch, forceNotUsedDataToNan)
%RUNHISTORY this is a pipeline of all update method

    if nargin == 1
        warningSwitch = 'on';
        forceNotUsedDataToNan = 0;
        warning('on');
    end
    
    try
        warning(warningSwitch);
    catch
        error("only 'on' or 'off' are valid!");
    end

    disp(['mode: History, warningMode:', char(warningSwitch)]);
    disp(['forceNotUsedDataToNan Status is:', num2str(forceNotUsedDataToNan)]);
    T = obj.getTradeableStockHistory();
    T = obj.checkStructAfterSelectionHistory(forceNotUsedDataToNan);
    clear T;

    warning('on');
end

