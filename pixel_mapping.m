function mperp = pixel_mapping(factors)

base_angstroom_per_pixel = 1075;
base_width = 1388;
base_height = 1040;

% calculate scanning/binning from picture size    
switch(factors.width)
    case 1388           % 1388x1040; base size: scan factor 1.0
        scanBin = 1;
    case 694            % 694x520
        scanBin = 4;
    case 462            % 462x346
        scanBin = 9;
    case 346            % 346x260
        scanBin = 16;    
    case 276            % 276x208
        scanBin = 25;
    case 2776           %2776x2080
        scanBin = 2;
    case 4164           %4164x3120
        scanBin = 3;
    otherwise
        scanBin = -1;    
end

% calculate micrometer per pixel 
mperp = base_angstroom_per_pixel;

if(factors.ocular == -1)
    factors.ocular = 5;
end
if (factors.tv == -1)
	factors.tv = 1;
end
if (scanBin == -1)
	scanBin = 1;    
end

% ocular factor
% base value is correct for objective magnification (=ocular factor) 20, the rest is calculated lineary
% if factors.ocular ~= 10
%     fprintf('Warning: Ocular factor correct? CurrentObjectiveMagnification = %d\nSetting it to 10.\n',factors.ocular)
%     factors.ocular=10;
% end


mperp = (mperp*20)/factors.ocular;
	
if (factors.tv == 1)
		%already ok in base value
elseif (factors.tv == 0)
		%TV adapter 1.0 assumed => as in base value	
else
    mperp = mperp / factors.tv;
end

switch (scanBin) 
	case 1
		mperp = mperp*3;
	case 2
		mperp = mperp*1.5;
	case 3
		%already ok in base value
        mperp = base_angstroom_per_pixel;
	case 4
		mperp = mperp * 6;
	case 9
		mperp = mperp * 9;
	case 16
		mperp = mperp * 12;
	case 25
		mperp = mperp * 15;
    otherwise
		% scanning 1 assumed
		mperp = mperp * 3;
end
	
% return in micrometer rather than Angstroom
mperp = mperp / 10000;
	    
fprintf('Pixel mapping used the following parameters: Base %d, TV %2.2f, Ocular %2.2f, scanBin %d\nresulting in mperp %2.5f\n',...
    base_angstroom_per_pixel,factors.tv,factors.ocular, scanBin, mperp);

end