function rts = calRts(processedClose, startTime)
targetClose = processedClose.close(end-startTime +1:end,:);
closeYesterday = processedClose.close(end-startTime:end-1,:);
rts = targetClose ./ closeYesterday -1;
end