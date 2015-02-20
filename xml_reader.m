% reads an xml file and returns corresponding Matlab structure

function factors = xml_reader(file)
   
    xmlstr =  xml_parseany(file);

    factors.ocular = str2num(strrep(xmlstr.CurrentObjectiveMagnification{1}.ATTRIBUTE.value,',','.'));
    factors.tv = str2num(strrep(xmlstr.CurrentTVAdapterMagnification{1}.ATTRIBUTE.value,',','.')); 
    %factors.width = str2num(xmlstr.PositionData{1}.PositionInformation{9}.PosInfoDimension{1}.ATTRIBUTE.width);
    factors.width = str2num(strrep(xmlstr.WavelengthData{1}.WavelengthInformation{1}.WLInfo{1}.ATTRIBUTE.width,',','.'));
    factors.offsetx = xmlstr.PositionData{1}.PositionInformation; 
    factors.offsety = xmlstr.PositionData{1}.PositionInformation;
    % positions comments auslesen
    positionTags = xmlstr.PositionData{1}.PositionInformation;
    positions = zeros(1,length(positionTags));
    comments = cell(1,length(positionTags));
    for i = 1:length(positionTags)
        
        comments{i} = positionTags{i}.PosInfoDimension{1}.ATTRIBUTE.comments;
        positions(i) = str2num(positionTags{i}.PosInfoDimension{1}.ATTRIBUTE.index);
        
    end
    
    factors.positions = positions;
    factors.comments = comments;

end

