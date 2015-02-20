function [res tracks]= tttParser(tttfile,xmlfilename)
% read file
tic

fid = fopen(tttfile);
res= [];
tracks=[];

if fid == -1
    fprintf('File not found %s\n',tttfile);

%     fclose(fid);
    return;
end

% read xml file and get values for coord mapping
try 
    xmlfile = fileread(xmlfilename);
    facs = xml_reader(xmlfile);
    
    % calculate micrometer per pixel factor
    pixelfactor = pixel_mapping(facs);
catch e
    fprintf('Could not open xml file %s\n',xmlfilename)
    fprintf('Trying to read ttt without it.\n')
    pixelfactor=1;
    facs=[];
end


res=[];
% - 4 bytes, int: version number
version = fread(fid,1,'uint32');
fprintf('Reading TTT file version %d...\n',version);

if version<15
    warning('TTT file version < 15 or unknown format. Cannot read file');
    fclose(fid);
    return
end

% - 4 bytes, int: last timepoint of the experiment
lastTP = fread(fid,1,'uint32');

% - 4 bytes, int: the number of tracks in the tree
numberOfTracks = fread(fid,1,'uint32');

% - 2 bytes, short int: maximum wavelength (-> mwl)
if version >= 18
    maximumWL = fread(fid,1,'uint16');
else
    maximumWL = 5;
end

% - 2 bytes, short int: tree finished (0 = false, 1 = true)
if version >=19
    treeFinished = fread(fid,1,'uint16');
end

% - 1 byte, bool: USE_NEW_POSITIONS, 0 (false, 1 = true) if old position-relative coordinates are used (like in fileversions <= 14), 1 if new experiment wide micrometer coordinates are used
if version >=20
    usenewpositions = fread(fid,1,'uint8');    
else
    usenewpositions = 1;
end

% beware of the swap!
if numberOfTracks>10000
    errordlg(sprintf('%s has more than 10000 tracks!??!',tttfile))
    fclose(fid);
    return;
end
tracks = cell(numberOfTracks,1);
counter = 0;
for track = 1:numberOfTracks
    % - for each track of the tree:
    %   - 4 bytes, int: track number
    out = fread(fid,2,'uint32');
    tracks{track}.trackNo = out(1);
    cellNr = tracks{track}.trackNo;
    
    
    %   - 4 bytes, int: starting timepoint
    tracks{track}.startTP = out(2);
    %   - 4 bytes, int: stopping timepoint (can be -1, indicating "not set")
    tracks{track}.stopTP = fread(fid,1,'int32');
    %   - 2 bytes, short int: stop reason (see enum TrackStopReason for values)
%     > enum TrackStopReason {TS_NONE = 0,
%     > TS_DIVISION = 1,
%     > TS_APOPTOSIS = 2,
%     > TS_LOST = 3}

    tracks{track}.stopReason = fread(fid,1,'uint16');
    %   - 4 bytes, int: number of trackpoints that were set for this track (how many marks did the user set)
    tracks{track}.NumberOfTrackpoints = fread(fid,1,'uint32');
    
    % beware of the swap!
    if tracks{track}.NumberOfTrackpoints>10000
        errordlg(sprintf('%s cell %d has more than 10000 trackpoints!??!',tttfile,cellNr))
        fclose(fid);
        return;
    end
    
    trackpoints = cell(tracks{track}.NumberOfTrackpoints,1);
    for trackpoint = 1:tracks{track}.NumberOfTrackpoints
        
        counter = counter + 1;
        
        res.stopReason(counter,1) = tracks{track}.stopReason;
        %   - for each trackpoint of the current track:
        %     - 2 bytes, short int: timepoint of this trackpoint
        trackpoints{trackpoint}.timepoint = fread(fid,1,'uint16');
        
        tp = trackpoints{trackpoint}.timepoint;
        res.cellNr(counter,1) = cellNr;
        res.timepoint(counter,1) = tp;
        
        
        %     - 4 bytes, float: X coordinate
        out = fread(fid,5,'float');
        trackpoints{trackpoint}.X = out(1)-1; % -1 because matlab is 1-based and coords are 0-based
        %     - 4 bytes, float: Y abscisse
        trackpoints{trackpoint}.Y =  out(2)-1; % -1 because matlab is 1-based and coords are 0-based;
        %     - 4 bytes, float: Z coordinate (not used currently)
        trackpoints{trackpoint}.Z = out(3);
        %     - 4 bytes, float: X background coordinate (only if a background track was set)
        trackpoints{trackpoint}.backgroundX =  out(4);
        %     - 4 bytes, float: Y background coordinate (only if a background track was set)
        trackpoints{trackpoint}.backgroundY =  out(5);
        %     - 1 byte, char:  tissue type (see trackpoint.h/cellproperties.h)
        out = fread(fid,3,'uint8');
        trackpoints{trackpoint}.tissueType = out(1);
        %     - 1 byte, char:  general type (see trackpoint.h/cellproperties.h)
        trackpoints{trackpoint}.generalType = out(2);
        %     - 1 byte, char:  lineage (see trackpoint.h)
        trackpoints{trackpoint}.lineage = out(3);
        %     - 2 bytes, short int: nonadherent (boolean: 0 = false, >0 = true)
        out = fread(fid,2,'uint16');
        trackpoints{trackpoint}.nonadherent = out(1);
        %     - 2 bytes, short int: freefloating (boolean)
        trackpoints{trackpoint}.freefloating = out(2);
        %     - 4 bytes, float:  cell radius (default = 25)
        if version <= 15
            trackpoints{trackpoint}.cellRadius = fread(fid,1,'uint8');
        else
            trackpoints{trackpoint}.cellRadius = fread(fid,1,'single');
        end
        %     - 2 bytes, short int: Endomitosis (boolean)
        trackpoints{trackpoint}.endomitosis = fread(fid,1,'uint16');
        %     - mwl*2 bytes, each short int: wavelength (1-mwl) on (boolean)
        trackpoints{trackpoint}.wavelengths = ones(0,maximumWL);
        if version <= 17
            %             for wl = 1:maximumWL
            trackpoints{trackpoint}.wavelengths(1:maximumWL) = fread(fid,maximumWL,'uint16');
            %             end
        else
            %             for wl = 1:maximumWL
            trackpoints{trackpoint}.wavelengths(1:maximumWL) = fread(fid,maximumWL,'uint8');
            %             end
        end
        %     - 4 bytes, long: additional attribute, for various purposes
        %%%% not shure but seems that since <v19 8byte??
        %%%% system dependend!?!?!
        if version <=18
            trackpoints{trackpoint}.additionalAttribute = fread(fid,1,'uint64');
        else
            trackpoints{trackpoint}.additionalAttribute = fread(fid,1,'uint32');
        end
        %     - 2 bytes, short int: positionn in which the trackpoint actually was set
        if version >= 17
            trackpoints{trackpoint}.position = fread(fid,1,'uint16');
        else
            trackpoints{trackpoint}.position = 0;
        end
        
        res.absoluteX(counter,1) = trackpoints{trackpoint}.X;
        res.absoluteY(counter,1) = trackpoints{trackpoint}.Y;
        
        
        % calculate coords with pixelfactor and offsets
        if trackpoints{trackpoint}.position ~= 0
            % get x & y offsets for the position
            if usenewpositions == 1 % remap position coords
                offset_x = str2num(strrep(facs.offsetx{facs.positions == trackpoints{trackpoint}.position}.PosInfoDimension{1}.ATTRIBUTE.posX,',','.'));
                offset_y = str2num(strrep(facs.offsety{facs.positions == trackpoints{trackpoint}.position}.PosInfoDimension{1}.ATTRIBUTE.posY,',','.'));
                trackpoints{trackpoint}.X = round(abs(trackpoints{trackpoint}.X - offset_x) / pixelfactor);
                trackpoints{trackpoint}.Y = round(abs(trackpoints{trackpoint}.Y - offset_y) / pixelfactor);
            end
        end
        
        if  trackpoints{trackpoint}.position == 0
            % map position from filename
            links = strfind(tttfile,'_p');
            trackpoints{trackpoint}.position = str2double(tttfile(links(1)+2:links(1)+4));
        end
        
        res.positionIndex(counter,1) = trackpoints{trackpoint}.position;
        res.X(counter,1) = trackpoints{trackpoint}.X;
        res.Y(counter,1) = trackpoints{trackpoint}.Y;
        res.wavelength_5(counter,1) = trackpoints{trackpoint}.wavelengths(5);
        res.wavelength_4(counter,1) = trackpoints{trackpoint}.wavelengths(4);
        res.wavelength_3(counter,1) = trackpoints{trackpoint}.wavelengths(3);
        res.wavelength_2(counter,1) = trackpoints{trackpoint}.wavelengths(2);
        res.wavelength_1(counter,1) = trackpoints{trackpoint}.wavelengths(1);
        res.freefloating(counter,1) = trackpoints{trackpoint}.freefloating;
        res.nonadherent(counter,1) = trackpoints{trackpoint}.nonadherent;
        res.endomitosis(counter,1) = trackpoints{trackpoint}.endomitosis; %%DS
        res.additionalAttribute(counter,1) = trackpoints{trackpoint}.additionalAttribute;
        res.tissueType(counter,1) = trackpoints{trackpoint}.tissueType;
        res.generalType(counter,1) = trackpoints{trackpoint}.generalType;
        res.lineage(counter,1) = trackpoints{trackpoint}.lineage;
    end
    
    tracks{track}.trackpoints=trackpoints;
end

posi = ftell(fid);
fseek(fid,0,'eof');
if posi == ftell(fid)
    fprintf('done with reading %s\n',tttfile);
else
    fprintf('!!! file %s not fully read\n',tttfile);
end
fclose(fid);
toc