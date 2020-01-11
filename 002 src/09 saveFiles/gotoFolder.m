function gotoFolder(fileDir)
    try
        cd(fileDir);
    catch
        disp('make a new folder')
        mkdir(fileDir);
        cd(fileDir);
    end
end