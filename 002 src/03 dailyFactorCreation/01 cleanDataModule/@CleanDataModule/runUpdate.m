function [] = runUpdate(obj, warningSwitch)
%RUNUPDATE this is a pipeline of all update method

    if nargin == 1
        warningSwitch = 'on';
        warning('on');
    end
    
    try
        warning(warningSwitch);
    catch
        error("only 'on' or 'off' are valid!");
    end

    disp(['mode: Update, warningMode:', char(warningSwitch)]);
    T = obj.getTradeableStockUpdate();
    T = obj.checkStructAfterSelectionUpdate();
    obj.getStructLastRow();
    clear T;

    warning('on');
end

