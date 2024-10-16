function sortedStructArray = complexFileSort(structArray)
    if ~isstruct(structArray)
        error('Input must be a struct array.');
    end

    if ~isfield(structArray, 'filename')
        error('The struct array must contain a field named ''filename''.');
    end

    fileList = {structArray.filename};
    
    filePattern = '^(?<prefix>[^\d]+)(?<date>\d{8})_(?<code>[A-Za-z\d]+)_(?<suffix1>[A-Za-z\d]+)_(?<suffix2>\d+)_?(?<extra>[A-Za-z\d_]*)\.(?<extension>\w+)$';
    fileInfo = regexp(fileList, filePattern, 'names');
    
    if isempty(fileInfo)
        error('No files match the specified pattern.');
    end
    
    % Convert date strings to numbers for proper sorting
    for i = 1:numel(fileInfo)
        fileInfo{i}.date = str2double(fileInfo{i}.date);
        fileInfo{i}.suffix2 = str2double(fileInfo{i}.suffix2);
    end
    
    % Sort the file names based on the captured groups
    [~, sortOrder] = sortrows(struct2table([fileInfo{:}]));
    sortedStructArray = structArray(sortOrder);
end
