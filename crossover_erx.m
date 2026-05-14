% Edge Recombination Crossover - cuva bridove iz oba roditelja.
function dijete = crossover_erx(r1, r2)
    n = length(r1);

    %susjedstvo
    susj = false(n, n);
    poz1 = zeros(1, n); poz1(r1) = 1:n;
    poz2 = zeros(1, n); poz2(r2) = 1:n;

    for i = 1:n
        ix1 = poz1(i);
        l1 = r1(mod(ix1-2, n)+1);
        d1 = r1(mod(ix1, n)+1);

        ix2 = poz2(i);
        l2 = r2(mod(ix2-2, n)+1);
        d2 = r2(mod(ix2, n)+1);

        susj(i, [l1, d1, l2, d2]) = true;
    end

    %stupanj
    stupanj = sum(susj, 2);

    dijete = zeros(1, n);
    posjecen = false(1, n);
    tren = r1(1);

    %izgradnja
    for i = 1:n
        dijete(i) = tren;
        posjecen(tren) = true;

        if i == n, break; end

        %azuriranje
        susjedi_tren = find(susj(:, tren));
        for j = 1:length(susjedi_tren)
            cilj = susjedi_tren(j);
            susj(cilj, tren) = false;
            stupanj(cilj) = stupanj(cilj) - 1;
        end

        %kandidati
        kand = find(susj(tren, :));
        kand = kand(~posjecen(kand));

        if isempty(kand)
            %slijepa
            neposj = find(~posjecen);
            tren = neposj(randi(length(neposj)));
        else
            %odabir
            stup_kand = stupanj(kand);
            min_st = min(stup_kand);
            najbolji = kand(stup_kand == min_st);

            if length(najbolji) > 1
                tren = najbolji(randi(length(najbolji)));
            else
                tren = najbolji;
            end
        end
    end
end
