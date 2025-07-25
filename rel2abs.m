function absolutePath = rel2abs(relativePath)
%REL2ABS Convert relative path to absolute path

    [status, attribs] = fileattrib(relativePath);
    
    if status
        absolutePath = attribs.Name;
    else
        error('Error getting file attributes')
    end

end