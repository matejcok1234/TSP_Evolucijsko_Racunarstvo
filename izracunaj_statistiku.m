% Racuna osnovnu statistiku (min, max, srednja, medijan, devijacija) iz sirovih podataka.
function izracunaj_statistiku()
    podaci = readtable('results/raw_results.csv');
    problemi = unique(podaci.Problem, 'stable');
    algos = unique(podaci.Algorithm, 'stable');

    %rezultati
    sazetak = table();

    for i = 1:length(problemi)
        for j = 1:length(algos)
            %filtriranje
            dio = podaci(strcmp(podaci.Problem, problemi{i}) & strcmp(podaci.Algorithm, algos{j}), :);

            if ~isempty(dio)
                redak = table();
                redak.Problem = problemi(i);
                redak.Algorithm = algos(j);
                redak.Min = min(dio.BestFitness);
                redak.Max = max(dio.BestFitness);
                redak.Mean = mean(dio.BestFitness);
                redak.Median = median(dio.BestFitness);
                redak.Std = std(dio.BestFitness);
                redak.AvgTime = mean(dio.TimeSeconds);

                sazetak = [sazetak; redak];
            end
        end
    end

    %spremanje
    writetable(sazetak, 'results/summary_results.csv');
end
