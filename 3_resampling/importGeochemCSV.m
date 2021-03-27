function imported = importGeochemCSV(dataCSV)
    opts = detectImportOptions(dataCSV, 'Delimiter', ',');
    % Note, except for Lith_Name, everything should be a double
    opts.VariableTypes(:) = {'double'};
    toMakeStrings = {'Original_Num', 'Sample_Notes', 'Ref_Title', ...
        'Ref_URL', 'Ref_DOI', 'Coll_Events_Notes', 'Env_Notes', 'Lith_Name'};
    for x = 1:length(toMakeStrings)
        [~, lithIdx] = find(strcmpi(toMakeStrings{x}, opts.VariableNames));
        opts.VariableTypes(lithIdx) = {'string'};
    end
    imported = readtable(dataCSV, opts);
end

