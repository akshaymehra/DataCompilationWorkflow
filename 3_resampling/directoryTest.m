function toTest = directoryTest(toTest)
    if ~isfolder(toTest)
        mkdir(toTest);
    end
end