function rectifiedFilename = rectifyFilename(proposedFilename)
    rectifiedFilename = matlab.lang.makeValidName(proposedFilename);
end