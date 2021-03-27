function plotForMehraMethods(dataCSV)
    close all
    dataset = importGeochemCSV(dataCSV);
    % Let's begin by illustrating the difference between CaO and Ca
    %% Differences between data collection and reporting methods
    % As exemplified by Ca vs CaO
    figure
    scatter(dataset.Ca / 10^4, dataset.CaO * (40.078/56.0774), ...
        'filled', 'MarkerFaceColor', 'black', 'MarkerFaceAlpha', 0.5);
    hold on
    plot(0:25, 0:25, 'color', 'red');
    grid on
    pbaspect([1,1,1]);
    xlim([0, 25]);
    ylim(xlim);
    xlabel('wt% Ca (from Ca)');
    ylabel('wt% Ca (from CaO)');
    legend({'Data', '1:1'}, 'Location', 'southeast');
    box on
    %% Now, let's consider 
    
end