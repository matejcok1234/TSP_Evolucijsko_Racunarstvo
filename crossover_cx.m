% Cycle Crossover - cuva apsolutne pozicije gradova iz roditelja.
function dijete = crossover_cx(r1, r2)
    n = length(r1);
    dijete = zeros(1, n);
    posjecen = false(1, n);

    %mapa
    mapa = zeros(1, n);
    mapa(r1) = 1:n;

    %ciklus
    tren = 1;
    while ~posjecen(tren)
        dijete(tren) = r1(tren);
        posjecen(tren) = true;
        val = r2(tren);
        tren = mapa(val);
    end

    %ostatak
    prazno = dijete == 0;
    dijete(prazno) = r2(prazno);
end
