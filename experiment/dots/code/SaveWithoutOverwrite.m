function SaveWithoutOverwrite(fileName, data)

[fPath, fName, fExt] = fileparts(fileName);
if isempty(fExt)  % No '.mat' in filename
    fExt = '.mat';
    fileName = fullfile(fPath, [fName, fExt]);
end

if exist(fileName, 'file')
    % Get number of files. 'ver' for version.
    fDir = dir(fullfile(fPath, [fName, 'ver', '*', fExt]));
    fStr = lower(sprintf('%s*', fDir.name));
    fNum = sscanf(fStr, [fName, 'ver', '%d', fExt, '*']);
    if isempty(fNum)
        newNum = 2;
    else
        newNum = max(fNum) + 1;
    end
    fileName = fullfile(fPath, [fName, 'ver', sprintf(...
        '%d', newNum), fExt]);
end

save(fileName, 'data');

end
