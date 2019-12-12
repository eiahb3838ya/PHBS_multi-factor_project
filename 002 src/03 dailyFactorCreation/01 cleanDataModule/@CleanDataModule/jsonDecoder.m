function outStruct= jsonDecoder(obj,fname)
%JSONDECODER decode json files to struct, valid thr. R2019b
%   Warning: if you are not using R2019b, must use other files!
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    outStruct = jsondecode(str);
end

