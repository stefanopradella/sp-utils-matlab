function iqdata = iqconvert(source, destination)
% Convert iq samples between common file formats.
% The function automatically detects the formats using file extensions.

    % TODO arguments
    
    %% Input file
    [~,~,inputFileExtension] = fileparts(source);
    
    switch inputFileExtension
        case ".mat"
            fileContent = load(source);
            fields = fieldnames(fileContent);
    
            for i = 1:numel(fields)
                fieldName = fields{i};
                isComplex = ~isreal(fileContent.(fieldName));
                isVector = max(size(fileContent.(fieldName))) > 1;
                if isComplex && isVector
                    break;
                end
            end

            I = real(fileContent.(fieldName));
            Q = imag(fileContent.(fieldName));

    end
    
    iqdata = I + 1i*Q;
    
    %% Output file
    [~,~,outputFileExtension] = fileparts(destination);
    
    switch outputFileExtension
        case '.cu8'
            interleavedIQ = [real(iqdata(:)).'; imag(iqdata(:)).'];
            interleavedIQ = round((interleavedIQ + 1) * 127.5);
            outputData = uint8(min(max(interleavedIQ, 0), 255));
    end

    fid_out = fopen(destination, 'wb');
    fileCleanup = onCleanup(@() fclose(fid_out));

    fwrite(fid_out, outputData, 'uint8');

end
