function [] = runHistory(obj, warningSwitch)
%RUNHISTORY this is a pipeline of all update method

    if nargin == 1
        warningSwitch = 'on';
        warning('on');
    end
    
    try
        warning(warningSwitch);
    catch
        error("only 'on' or 'off' are valid!");
    end

    disp(['mode: History, warningMode:', char(warningSwitch)]);
    T = obj.getTradeableStockHistory();
    T = obj.checkStructAfterSelectionHistory();
    clear T;

    warning('on');
end

