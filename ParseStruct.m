function MyStruct = ParseStruct(MyStruct, Line, BigEndianness)
%% Function to Parse an HEXadecimal line of text into a predefined struct,
%    making sure that the amount of bytes in the input matches the amount of 
%    bytes in the struct.

if nargin < 3
    BigEndianness = false;
end

VarsInStruct  = fieldnames(MyStruct);
NVarsInStruct = length(VarsInStruct);
LengthLine    = length(Line);

varBytesTotal = 0;
Index = 1;
for iVars = 1:NVarsInStruct
    var = getfield(MyStruct,VarsInStruct{iVars});
    varClass = class(var);
    % typecast(uint16(hex2dec('FFFF')),'int16') == -1;
    
    varBytes = 0;
    % The first cast has to be made to a unsigned integer of the size of
    % the data, even if it is a floating point value.
    %   \todo assert(isnumeric
    if isa(var,'double')
        castClass = 'uint64';
        tmpvar = double(0);
    elseif isa(var,'single')
        castClass = 'uint32';
        tmpvar = single(0);
    elseif varClass(1) ~= 'u'
        % append unsigned to any other integer
        castClass = ['u' varClass];
        tmpvar = getfield(MyStruct,VarsInStruct{iVars});
    elseif varClass(1) == 'u'
        tmpvar = getfield(MyStruct,VarsInStruct{iVars});
        castClass = varClass;
    else
        disp('[ERROR] Something went wrong, probably variable is not numeric');
    end

    if varBytes == 0
        varBytes = SizeInBytes(tmpvar);
    end
    
    if (BigEndianness)
        Line = reshape([Line(end-1:-2:1); Line(end:-2:1)], 1,length(Line));
    end
    
    stringValue = Line(Index:Index+2*varBytes-1);
    decValue = typecast(cast(hex2dec(stringValue),castClass), varClass);
    if isempty(decValue)
        decValue = cast(0, varClass);
    end
    
    MyStruct = setfield(MyStruct, VarsInStruct{iVars}, decValue);

    Index = Index + 2*varBytes;
    varBytesTotal = varBytesTotal + varBytes;

end

try
    assert(2*varBytesTotal == LengthLine);
catch
    disp('[ERROR] Parsing structure');
end

end
