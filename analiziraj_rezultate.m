% Radi Friedmanov test, Kendallov W i Wilcoxonovu analizu na temelju medijana.
function analiziraj_rezultate()
    podaci = readtable('results/summary_results.csv');
    problemi = unique(podaci.Problem, 'stable');
    algos = unique(podaci.Algorithm, 'stable');

    N = length(problemi);
    k = length(algos);
    matrica_med = zeros(N, k);

    %medijani
    tab_medijani = table();
    tab_medijani.Problem = problemi;

    for j = 1:k
        stupac = zeros(N, 1);
        for i = 1:N
            idx = strcmp(podaci.Problem, problemi{i}) & strcmp(podaci.Algorithm, algos{j});
            if any(idx)
                stupac(i) = podaci.Median(idx);
                matrica_med(i, j) = podaci.Median(idx);
            end
        end
        tab_medijani.(algos{j}) = stupac;
    end
    writetable(tab_medijani, 'results/tablica_3_medijani.csv');

    %friedman
    [p_friedman, tab_f, ~] = friedman(matrica_med, 1, 'off');

    %rangovi
    mat_rangovi = zeros(N, k);
    for i = 1:N
        red = matrica_med(i, :);
        mat_rangovi(i, :) = tiedrank(red);
    end

    tab_rangovi = table();
    tab_rangovi.Problem = problemi;
    for j = 1:k
        tab_rangovi.(algos{j}) = mat_rangovi(:, j);
    end
    writetable(tab_rangovi, 'results/tablica_4_rangovi.csv');

    %prosjek
    prosjeci = mean(mat_rangovi, 1);
    tab_prosjeci = table();
    tab_prosjeci.Algoritam = algos;
    tab_prosjeci.ProsjecniRang = prosjeci';
    writetable(tab_prosjeci, 'results/tablica_5_prosjecni_rangovi.csv');

    %kendall
    chi2 = tab_f{2, 5};
    W = chi2 / (N * (k - 1));

    fid = fopen('results/friedman_test.csv', 'w');
    fprintf(fid, 'P_Friedman,Chi2,Kendall_W\n');
    fprintf(fid, '%f,%f,%f\n', p_friedman, chi2, W);
    fclose(fid);

    %wilcoxon
    if p_friedman < 0.05
        par = {[1,2], [1,3], [2,3]};
        nazivi = {['' algos{1} '-' algos{2}], ['' algos{1} '-' algos{3}], ['' algos{2} '-' algos{3}]};
        p_vrijednosti = zeros(1, 3);

        for i = 1:3
            p_vrijednosti(i) = signrank(matrica_med(:, par{i}(1)), matrica_med(:, par{i}(2)));
        end

        [p_korig, znacajno] = holm_korekcija(p_vrijednosti, 0.05);

        fid = fopen('results/post_hoc_holm.csv', 'w');
        fprintf(fid, 'Usporedba,P_vrijednost,P_korigirano,Znacajno\n');
        for i = 1:3
            fprintf(fid, '%s,%f,%f,%d\n', nazivi{i}, p_vrijednosti(i), p_korig(i), znacajno(i));
        end
        fclose(fid);
    end
end

% Holmova korekcija
function [p_korigirano, znacajno] = holm_korekcija(p_vrijednosti, alfa)
    m = length(p_vrijednosti);
    [p_sort, idx] = sort(p_vrijednosti);
    p_korigirano = zeros(size(p_vrijednosti));
    znacajno = zeros(size(p_vrijednosti));

    for i = 1:m
        prag = alfa / (m - i + 1);
        p_korigirano(idx(i)) = p_sort(i) * (m - i + 1);
        if p_sort(i) < prag
            znacajno(idx(i)) = 1;
        else
            break;
        end
    end
    p_korigirano = min(p_korigirano, 1);
end
