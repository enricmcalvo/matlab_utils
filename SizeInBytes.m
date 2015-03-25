function bytes = SizeInBytes(tmpvar)

if isnumeric(tmpvar)
    tmpwhos = whos('tmpvar');
    bytes = tmpwhos.bytes;
else
    disp('[INFO] Non-numeric variable passed');
    bytes = 0;
end

% Consider 'struct' variables!!!

end

