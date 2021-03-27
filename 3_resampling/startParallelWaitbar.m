function [dataQueue, bar] = startParallelWaitbar(numSteps)
    dataQueue = parallel.pool.DataQueue;
    bar = waitbar(0, 'Processing');
    afterEach(dataQueue, @nUpdateWaitbar);
    counter = 1;
 
    function nUpdateWaitbar(~)
        progressString = strcat(num2str((counter/numSteps) * 100), "% complete");
        waitbar(counter/numSteps, bar, progressString);
        counter = counter + 1;
    end

end