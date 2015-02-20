% INTRODUCTION
% ============
% - FileVersion: 		01
% - FileExtension:	.log
% 
% - Binary file with timestamp for every picture
% 
% - All values are stored in Little-Endian format
% 
% - Floating  point number are saved in the IEEE 754 format with 32 bit precision
% 
% 
% 
% FORMAT SPECIFICATION
% ====================
% 
% - 4 bytes: signature (magic number) to identify a valid log file: 0x6C 0x6F 0x67 0x66 ("logf" in ASCII)
% - 4 bytes: unsigned integer: Fileversion
% - 4 bytes, unsigned integer: Number of w0 files (more accurately: maximal timepoint + 1 of pictures in current position)
% - 4 bytes, unsigned integer: Number of wavelengths
% - 4 bytes, unsigned integer: Number of file entries
% - For each file entry:
% 	- 4 bytes, unsigned integer: TimePoint of entry
% 	- 2 bytes, unsigned integer: Wavelength of entry
% 	- 2 bytes, signed integer: Z-Index of file or -1 if no z-index exists
% 	- 8 bytes, unsigned integer: date and time of image acquisition as the number of milliseconds that have passed since 1970-01-01T00:00:00.000, Coordinated Universal Time.

function res=positionLogFileReader(logfilename)
% read file
fprintf('Reading Logfile %s ...',logfilename);
fid = fopen(logfilename);
res=[];
if fid == -1
    fprintf('File not found %s.\n',logfilename);
%     fclose(fid);    
    return;
end

% - 4 bytes: signature (magic number) to identify a valid log file: 0x6C 0x6F 0x67 0x66 ("logf" in ASCII)
signature = (fread(fid,4,'*char'))';

if ~strcmp(signature,'logf')
    fprintf('File signature ''%s'' wrong.\n',signature);
    fclose(fid);    
    return;
end


% - 4 bytes: unsigned integer: Fileversion
version = fread(fid,1,'uint32');

% - 4 bytes, unsigned integer: Number of w0 files (more accurately: maximal timepoint + 1 of pictures in current position)
numelw0 = fread(fid,1,'uint32');

% - 4 bytes, unsigned integer: Number of wavelengths
numelwl = fread(fid,1,'uint32');

% - 4 bytes, unsigned integer: Number of file entries
numelfiles = fread(fid,1,'uint32');

res.timepoint = zeros(1,numelfiles);
res.wavelength = zeros(1,numelfiles);
res.zindex  = zeros(1,numelfiles);
res.absoluteTime = zeros(1,numelfiles);

% - For each file entry:
for f = 1:numelfiles

% 	- 4 bytes, unsigned integer: TimePoint of entry
    res.timepoint(f) = fread(fid,1,'uint32');

% 	- 2 bytes, unsigned integer: Wavelength of entry
    res.wavelength(f) = fread(fid,1,'uint16');
    
% 	- 2 bytes, signed integer: Z-Index of file or -1 if no z-index exists
    res.zindex(f) = fread(fid,1,'int16');

% 	- 8 bytes, unsigned integer: date and time of image acquisition as the number of milliseconds that have passed since 1970-01-01T00:00:00.000, Coordinated Universal Time.
    res.absoluteTime(f) = fread(fid,1,'uint64');

end

% norm absolute time to seconds after Jan-1-0000 00:00:00
res.absoluteTime = res.absoluteTime./1000;
res.absoluteTime = res.absoluteTime+datenum('1970-01-01 00:00:00.000')*60*60*24;

posi = ftell(fid);
fseek(fid,0,'eof');
if posi == ftell(fid)
    fprintf('done with reading %s\n',logfilename);
else
    fprintf('!!! file %s not fully read\n',logfilename);
end
fclose(fid);


