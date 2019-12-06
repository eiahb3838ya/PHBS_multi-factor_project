function [X, offsetSize] = LNCAP(stock)
% Returns the log value of the total market capital of single stocks
% log(total market capital)
% stock is a structure

% clean data module here

% get factor module here
    [X, offsetSize] = getLNCAP(stock.properties.totalMktCap);
end

%-------------------------------------------------------------------------

function [exposure, offsetSize] = getLNCAP(totalMktCap)
% function compute factor exposure of style factor
    exposure = log(totalMktCap);
    offsetSize = 1;
end