% Ucitava .tsp datoteku i vraca koordinate gradova i ime problema.
function [koord, naziv] = ucitaj_tsp(putanja)
    fid = fopen(putanja, 'r');
    if fid == -1, error('Ne mogu otvoriti: %s', putanja); end

    %zaglavlje
    naziv = '';
    dim = 0;
    while true
        linija = fgetl(fid);
        if ~ischar(linija), break; end
        linija = strtrim(linija);
        if startsWith(linija, 'NAME'), naziv = strtrim(extractAfter(linija, ':')); end
        if startsWith(linija, 'DIMENSION'), dim = str2double(strtrim(extractAfter(linija, ':'))); end
        if startsWith(linija, 'NODE_COORD_SECTION'), break; end
    end

    %koordinate
    if dim > 0
        koord = zeros(dim, 2);
        for i = 1:dim
            linija = fgetl(fid);
            v = sscanf(linija, '%f');
            if length(v) >= 3
                koord(i, :) = v(2:3)';
            end
        end
    else
        matrica = fscanf(fid, '%f', [3, inf])';
        koord = matrica(:, 2:3);
    end
    fclose(fid);

    if isempty(naziv), naziv = 'Nepoznato'; end
end
