function [] = runUpdate(obj, warningSwitch, forceNotUsedDataToNan)
%RUNUPDATE this is a pipeline of all update method

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

    disp(['mode: Update, warningMode:', char(warningSwitch)]);
    disp(['forceNotUsedDataToNan Status is:', num2str(forceNotUsedDataToNan)]);
    T = obj.getTradeableStockUpdate();
    T = obj.checkStructAfterSelectionUpdate(forceNotUsedDataToNan);

    
    obj.getStructLastRow();
    clear T;

    warning('on');
end

