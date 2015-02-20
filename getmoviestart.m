function moviestart = getmoviestart(imgroot)

% try to read log file of first position

d1 = dir([imgroot '/*_p*']);
try
    res=positionLogFileReader([imgroot '/' d1(1).name '/' d1(1).name '.log']);
    moviestart = min(res.absoluteTime);
    return
catch e
    errordlg('Position-Log file error: Moviestart could not be determined.')
    moviestart = 0;
%     return
end


%%%% OUTDATED, will not parse XML anymore by myself...
% get movie start time
d1 = dir([imgroot '/*_p*']);
d2 = dir([imgroot '/' d1(1).name '/*xml']);
xmlfilename=[imgroot '/' d1(1).name '/' d2(1).name];
xmlfile = fileread(xmlfilename);
fprintf('Using file %s to determine moviestart.\n',d2(1).name)
try
    coords=strfind(xmlfile,'V42');
    abstime = datenum(xmlfile(coords(1)+4:coords(2)-3),'yyyy-mm-dd HH:MM:SS')* 60 * 60 * 24;
catch e
    coords=strfind(xmlfile,'V41');
    abstime = datenum(xmlfile(coords(1)+4:coords(2)-3),'yyyy-mm-dd HH:MM:SS')* 60 * 60 * 24;
end

moviestart = abstime;
end
