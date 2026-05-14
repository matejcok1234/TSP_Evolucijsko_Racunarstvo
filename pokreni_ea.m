% Evolucijski algoritam za TSP - turnirska selekcija, krizanje, inverzija.
% Vraca najbolji fitness, vrijeme, broj generacija, rutu i krivulju konvergencije.
function [naj_fit, vrijeme, gen, naj_ruta, krivulja] = pokreni_ea(koord, vel_pop, maks_gen, stall_limit, pc, pm, tip)
    tic;
    n = size(koord, 1);
    dist = squareform(pdist(koord));

    %inicijalizacija
    pop = zeros(vel_pop, n);
    for i = 1:vel_pop, pop(i,:) = randperm(n); end

    %fitness
    fit = zeros(vel_pop, 1);
    for i = 1:vel_pop
        ruta = pop(i,:);
        fit(i) = sum(diag(dist(ruta, [ruta(2:end), ruta(1)])));
    end

    [naj_fit, idx] = min(fit);
    naj_ruta = pop(idx, :);
    stall = 0;

    %konvergencija
    krivulja = zeros(1, maks_gen);
    krivulja(1) = naj_fit;

    %petlja
    for g = 1:maks_gen
        nova_pop = pop;
        nova_pop(1, :) = naj_ruta;

        for i = 2:vel_pop
            %selekcija
            t1 = randi(vel_pop, 1, 3); [~, b1] = min(fit(t1)); r1 = pop(t1(b1), :);
            t2 = randi(vel_pop, 1, 3); [~, b2] = min(fit(t2)); r2 = pop(t2(b2), :);

            %krizanje
            if rand() < pc
                switch tip
                    case 'CX',  dijete = crossover_cx(r1, r2);
                    case 'SX',  dijete = crossover_sx(r1, r2);
                    case 'ERX', dijete = crossover_erx(r1, r2);
                    otherwise,  dijete = r1;
                end
            else
                dijete = r1;
            end

            %mutacija
            if rand() < pm
                m = randi(n, 1, 2);
                i1 = min(m); i2 = max(m);
                dijete(i1:i2) = fliplr(dijete(i1:i2));
            end
            nova_pop(i, :) = dijete;
        end

        %azuriranje
        pop = nova_pop;
        for i = 1:vel_pop
            ruta = pop(i,:);
            fit(i) = sum(diag(dist(ruta, [ruta(2:end), ruta(1)])));
        end

        [tren_fit, idx] = min(fit);
        if tren_fit < naj_fit
            naj_fit = tren_fit;
            naj_ruta = pop(idx, :);
            stall = 0;
        else
            stall = stall + 1;
        end

        krivulja(g) = naj_fit;
        if stall >= stall_limit, break; end
    end

    vrijeme = toc;
    gen = g;
    krivulja = krivulja(1:g);
end
