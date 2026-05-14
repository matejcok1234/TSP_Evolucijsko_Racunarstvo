% Simple Crossover - jednorezni crossover za permutacije.
function dijete = crossover_sx(r1, r2)
    n = length(r1);
    tocka = randi([1, n-1]);

    dijete = zeros(1, n);
    dijete(1:tocka) = r1(1:tocka);

    %popunjavanje
    zauzet = false(1, n);
    zauzet(dijete(1:tocka)) = true;

    poz = tocka + 1;
    for i = 1:n
        grad = r2(i);
        if ~zauzet(grad)
            dijete(poz) = grad;
            poz = poz + 1;
            zauzet(grad) = true;
        end
    end
end
