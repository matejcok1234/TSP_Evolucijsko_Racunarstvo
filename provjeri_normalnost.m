% Provjerava normalnost distribucije rezultata pomocu Shapiro-Wilk testa.
function provjeri_normalnost()
    podaci = readtable('results/raw_results.csv');
    problemi = unique(podaci.Problem, 'stable');
    algos = unique(podaci.Algorithm, 'stable');

    %spremanje
    fid = fopen('results/normalnost.csv', 'w');
    fprintf(fid, 'Problem,Algoritam,ShapiroWilk_P,Normalna\n');

    for i = 1:length(problemi)
        for j = 1:length(algos)
            uzorak = podaci.BestFitness(strcmp(podaci.Problem, problemi{i}) & strcmp(podaci.Algorithm, algos{j}));

            %test
            try
                [h, p_vrijednost] = swtest(uzorak, 0.05);
                normalna = ~h;
            catch
                %greska
                p_vrijednost = NaN; normalna = NaN;
            end

            fprintf(fid, '%s,%s,%f,%d\n', problemi{i}, algos{j}, p_vrijednost, normalna);
        end
    end
    fclose(fid);
end
