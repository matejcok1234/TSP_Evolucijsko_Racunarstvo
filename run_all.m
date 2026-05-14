% Glavna skripta koja pokrece cijeli eksperiment i sprema rezultate u CSV.
% Generira vlastite TSP probleme ako ne postoje, pa redom testira svaki algoritam.
clear; close all; clc;
tic;

%problemi
tsplib = {...
    'data/tsplib/berlin52.tsp', ...
    'data/tsplib/kroC100.tsp', ...
    'data/tsplib/kroD100.tsp', ...
    'data/tsplib/kroE100.tsp', ...
    'data/tsplib/rat99.tsp', ...
    'data/tsplib/st70.tsp', ...
    'data/tsplib/Croatia50.tsp'};

%generiranje
if ~exist('data/generated', 'dir'), mkdir('data/generated'); end
vlastiti = {'data/generated/vlastiti_uniform60.tsp', ...
            'data/generated/vlastiti_clustered55.tsp', ...
            'data/generated/vlastiti_circle45.tsp'};

if ~exist(vlastiti{1}, 'file')
    koord1 = rand(60, 2) * 1000;
    koord2 = [rand(25, 2)*300; rand(30, 2)*300 + 700];
    t = linspace(0, 2*pi, 46)'; t = t(1:end-1);
    koord3 = [500 + 400*cos(t), 500 + 400*sin(t)];

    spremi_tsp(vlastiti{1}, koord1, 'vlastiti_uniform60');
    spremi_tsp(vlastiti{2}, koord2, 'vlastiti_clustered55');
    spremi_tsp(vlastiti{3}, koord3, 'vlastiti_circle45');
end

svi_problemi = [tsplib, vlastiti];
algos = {'CX', 'SX', 'ERX'};

%parametri
vel_pop = 120;
maks_gen = 1000;
stall = 150;
pc = 0.60;
pm = 0.35;
br_pokretanja = 30;

%mape
if ~exist('results', 'dir'), mkdir('results'); end
if ~exist('figures', 'dir'), mkdir('figures'); end

%csv
fid = fopen('results/raw_results.csv', 'w');
fprintf(fid, 'Problem,Algorithm,Run,BestFitness,TimeSeconds\n');

%eksperiment
fprintf('Pokrecem eksperimente (ukupno 900 pokretanja)...\n');
for p = 1:length(svi_problemi)
    [koord, ime] = ucitaj_tsp(svi_problemi{p});
    fprintf('  Problem: %s\n', ime);

    for a = 1:length(algos)
        fprintf('    %s ', algos{a});
        for r = 1:br_pokretanja
            rng(r);
            [fit, vrijeme] = pokreni_ea(koord, vel_pop, maks_gen, stall, pc, pm, algos{a});
            fprintf(fid, '%s,%s,%d,%f,%f\n', ime, algos{a}, r, fit, vrijeme);
            fprintf('.');
        end
        fprintf(' OK\n');
    end
end
fclose(fid);

%analiza
fprintf('Statistika i grafovi...\n');
izracunaj_statistiku();
provjeri_normalnost();
analiziraj_rezultate();
crtaj_grafove();

fprintf('\nGotovo! Vrijeme: %.2f s\n', toc);

function spremi_tsp(putanja, koord, naziv)
    f = fopen(putanja, 'w');
    fprintf(f, 'NAME: %s\nTYPE: TSP\nDIMENSION: %d\nEDGE_WEIGHT_TYPE: EUC_2D\nNODE_COORD_SECTION\n', naziv, size(koord,1));
    for i = 1:size(koord,1)
        fprintf(f, '%d %f %f\n', i, koord(i,1), koord(i,2));
    end
    fclose(f);
end
