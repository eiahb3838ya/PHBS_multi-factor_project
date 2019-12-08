function outStruct= testJsonDecoder(fname)
%JSONDECODER Summary of this function goes here
%   Detailed explanation goes here
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    outStruct = jsondecode(str);
end

