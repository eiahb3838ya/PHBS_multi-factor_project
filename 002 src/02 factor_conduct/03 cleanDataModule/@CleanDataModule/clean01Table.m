function [indicatorMatrix,offsetSize] = clean01Table(rawDataStruct,cleanParamStruct)
%CLEAN01TABLE clean 0-1 tables
%   To disable a rule, please set rollingSize parameter to 0
%   To distiguish 0 and 1's real-world meaning, use settingValidIndicator,
%   if indicator is 1, means data == 1 should be reserved, otherwise, means
%   data == 0 should be reserved.

    % step 0: check cleanParamStruct validity
    if length(cleanParamStruct.settingRefer01Table) ~= length(cleanParamStruct.settingValidIndicator)
        error 'param structure error! settingRefer01 must match settingValidIndicator!';
    end
    
    if ~isfield(cleanParamStruct, "settingRefer01Table")
        error 'Not define 0-1 table for reference!';
    else
        tableAddr = cell(length(cleanParamStruct.settingRefer01Table));
        refTables = cell(length(cleanParamStruct.settingRefer01Table));
        refValidIndicator = cell(length(cleanParamStruct.settingValidIndicator));
        for count = 1:length(cleanParamStruct.settingRefer01Table)
            tableAddr{count} = string(cleanParamStruct.settingRefer01Table{count});
            refTables{count} = parseStringToStructPath(rawDataStruct,tableAddr{count});
            refValidIndicator{count} = cleanParamStruct.settingValidIndicator(count);
        end
        
        % check if read ref table successfully and whether ref table is
        % useable
        for count = 1:length(cleanParamStruct.settingRefer01Table)
            if isempty(refTables{count})
%                 disp(['for table: ', tableAddr(count)]);
                error('fail to read "%s" table, because it is empty!', tableAddr{count});
            end
            if sum(isnan(refTables{count}),'all')~=0
%                 disp(['for table: ', tableAddr(count)]);
                error('fail to read "%s" table, because it has nan!', tableAddr{count});
            end
            if ~(isequal(unique(refTables{count}),[0,1]) ||...
                    isequal(unique(refTables{count}),[0;1]))
                error 'elements other than 0,1 exist!';
            end
        end
    end
    
    % step2: according to 
    %                                    |-- maxConsecutiveInvalidLength
    %                                    |-- maxConsecutiveRollingSize
    %                                    |-- maxCumulativeInvalidLength     
    %                                    |-- maxCumulativeRollingSize
    %                                    |-- noToleranceRollingSize
    %                                    |-- flag
    % use for loop to clean the data(simulate the situation where you are on the last day of a rolling window)
    % if table size(#rows) is smaller than maximum of rolling size, throw
    % error
    % 1 is invalid, 0 is valid
    maxConsecutiveInvalidLength = cleanParamStruct.settingClean01.maxConsecutiveInvalidLength;
    maxConsecutiveRollingSize = cleanParamStruct.settingClean01.maxConsecutiveRollingSize;
    maxCumulativeInvalidLength = cleanParamStruct.settingClean01.maxCumulativeInvalidLength;
    maxCumulativeRollingSize = cleanParamStruct.settingClean01.maxCumulativeRollingSize;
    noToleranceRollingSize = cleanParamStruct.settingClean01.noToleranceRollingSize;
    flag = cleanParamStruct.settingClean01.flag;
    % and refValidIndicator
    
    %check validity of params
    if (maxConsecutiveInvalidLength > maxConsecutiveRollingSize) ||...
            (maxCumulativeInvalidLength > maxCumulativeRollingSize)
        error 'rolling size must be >= invalid length.';
    end
    
    if (maxConsecutiveRollingSize > maxCumulativeRollingSize) ||...
            (maxConsecutiveRollingSize < noToleranceRollingSize)
        error 'should be:cumulative rolling size >=consecutive rolling size >= no tolerance rolling size; otherwise params are senesless.';
    end
    
    % init controller and result
    caseController = [maxCumulativeRollingSize, maxConsecutiveRollingSize, noToleranceRollingSize] ~= 0;
    indicatorMatrix = ones(size(refTables{1}));
    
    %start clean 0-1 table
    % first, for all table, use 1 to represent invalid, 0 represent valid
    for count = 1:length(refValidIndicator)
        if refValidIndicator{count} == 1
            refTables{count} = 1 - refTables{count};
        end
    end
    
    % start case choice
    %caseController = [maxCumulativeRollingSize, maxConsecutiveRollingSize, noToleranceRollingSize] ~= 0;
    choiceIndex = caseController.*[1,2,3];
    try 
        for count = 1:length(refTables)
            currentTable = refTables{count};
            cumulativeRuleResult = dealCumulativeRule(currentTable, maxCumulativeInvalidLength, maxCumulativeRollingSize);
            consecutiveRuleResult = dealConsecutiveRule(currentTable, maxConsecutiveInvalidLength, maxConsecutiveRollingSize);
            noToleranceRuleResult = dealNoToleranceRule(currentTable, noToleranceRollingSize);
            cellRuleResults = {cumulativeRuleResult, consecutiveRuleResult, noToleranceRuleResult};
            for mat = cellRuleResults(choiceIndex)
                indicatorMatrix = indicatorMatrix.*mat{:};
            end
        end
    catch
        error 'ref tables size not match!';
    end
    
    % step 3: according to flag, choose output format
    if flag == 1
        offsetSize = max([maxCumulativeRollingSize, maxConsecutiveRollingSize, noToleranceRollingSize])-1;%because it is size, not starting index
        indicatorMatrix = prod(indicatorMatrix(offsetSize+1:end,:),1);
    end

end

function consecutiveRuleResult = dealConsecutiveRule(table01, maxConsecutiveInvalidLength, maxConsecutiveRollingSize)
%DEALCONSECUTIVERULE to deal with max consecutive invalid length and its
%rolling size.
%Caution: this is not an independent method, should not be called
%independently! If being called independently, please manully check the
%parameter is correct!
%default example, stDay, where 1 is invalid, 0 is valid

consecutiveRuleResult = zeros(size(table01));

%get slice 
for rowC = maxConsecutiveRollingSize:size(table01,1)
    slice = table01(rowC - maxConsecutiveRollingSize + 1:rowC,:);
    for col = 1:size(slice,2)
        expandColumn = [1; diff(slice(:,col))~=0; 1]; %1 if value changes
        repetitionTimeConsecutiveNumber = diff(find(expandColumn));
        repetitionTimeBackToArray = repelem(repetitionTimeConsecutiveNumber, repetitionTimeConsecutiveNumber);
        maxConsecutiveDay = max(repetitionTimeBackToArray(slice(:,col)==1));
        if isempty(maxConsecutiveDay) 
            consecutiveRuleResult(rowC,col) = 0;
        else
            consecutiveRuleResult(rowC,col) = maxConsecutiveDay;
        end
    end
end
consecutiveRuleResult = consecutiveRuleResult <= maxConsecutiveInvalidLength;
consecutiveRuleResult(1:maxConsecutiveRollingSize-1,:) = 0;

end

function cumulativeRuleResult = dealCumulativeRule(table01, maxCumulativeInvalidLength, maxCumulativeRollingSize)
%DEALCUMULATIVERULE to deal with max cumulative invalid length and its
%rolling size.
%Caution: this is not an independent method, should not be called
%independently! If being called independently, please manully check the
%parameter is correct!
%default example, stDay, where 1 is invalid, 0 is valid

cumulativeRuleResult = zeros(size(table01));

%get slice
for rowC = maxCumulativeRollingSize:size(table01,1)
    slice = table01(rowC - maxCumulativeRollingSize + 1:rowC,:);
    judgeSlice = sum(slice,1);
    cumulativeRuleResult(rowC,:) = judgeSlice;
end

cumulativeRuleResult = cumulativeRuleResult <= maxCumulativeInvalidLength;
cumulativeRuleResult(1:maxCumulativeRollingSize-1,:) = 0;

end

function noToleranceRuleResult = dealNoToleranceRule(table01, noToleranceRollingSize)
%DEALNOTOLERANCERULE to deal with no tolerance rule
%Caution: this is not an independent method, should not be called
%independently! If being called independently, please manully check the
%parameter is correct!
%default example, stDay, where 1 is invalid, 0 is valid

noToleranceRuleResult = zeros(size(table01));

%get slice
for rowC = noToleranceRollingSize:size(table01,1)
    slice = table01(rowC - noToleranceRollingSize + 1:rowC,:);
    judgeSlice = sum(slice,1);
    noToleranceRuleResult(rowC,:) = judgeSlice;
end

noToleranceRuleResult = noToleranceRuleResult == 0;
noToleranceRuleResult(1:noToleranceRollingSize-1,:) = 0;

end

function v = parseStringToStructPath(S, fieldlist)

%     v = eval(['S.' fieldlist]);

  fn = regexp(fieldlist, '\.', 'split');
  bad_fields = fn(cellfun(@isempty,regexp(fn, '^[A-Za-z][A-Za-z0-9_]*$')));
  if ~isempty(bad_fields)
     error('Only plain fieldnames are allowed. First invalid one is "%s"', bad_fields{1});
  end
  v = S;
  for K = 1 : length(fn)
     thisfn = fn{K};
     if isfield(v, thisfn)
       if length(v) == 1
         v = v.(thisfn);
       else
         error('MATLAB:dotRefOnNonScalar', 'Dot name reference on non-scalar structure. Field "%s"', strjoin(fn(1:K), '.'));
       end
     else
       error('Field "%s" does not exist in structure', strjoin(fn(1:K), '.'));
     end
  end
end




