% Generira sve potrebne slike (boxplot, histogrami, konvergencija, mape).
function crtaj_grafove()
    clc;
    folder = 'figures';
    if ~exist(folder, 'dir'), mkdir(folder); end

    boje = {[0.2 0.45 0.8], [0.15 0.65 0.3], [0.85 0.45 0.1]};
    algos = {'CX', 'SX', 'ERX'};

    %ucitavanje
    raw = readtable('results/raw_results.csv');
    res = readtable('results/summary_results.csv');
    problemi = unique(raw.Problem, 'stable');

    % 1. Boxplotovi
    for pi = 1:length(problemi)
        p = problemi{pi};
        podaci = raw(strcmp(raw.Problem, p), :);

        fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 600 420]);
        ax = axes(fig);
        hold(ax, 'on');

        for ai = 1:length(algos)
            vrijednosti = podaci.BestFitness(strcmp(podaci.Algorithm, algos{ai}));
            moj_boxplot(ax, vrijednosti, ai, boje{ai});
        end

        ax.XTick = 1:3;
        ax.XTickLabel = algos;
        ax.FontSize = 13;
        ylabel(ax, 'Duljina rute', 'FontWeight', 'bold');
        title(ax, ['Distribucija: ' p], 'Interpreter', 'none');
        grid(ax, 'on');

        exportgraphics(fig, fullfile(folder, ['boxplot_' p '.png']), 'Resolution', 200);
        close(fig);
    end

    % 2. Histogrami
    hist_prob = {'berlin52', 'kroC100', 'Croatia50_EUC2D'};
    for pi = 1:length(hist_prob)
        p = hist_prob{pi};
        podaci = raw(strcmp(raw.Problem, p), :);
        if isempty(podaci), continue; end

        fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 900 350]);
        for ai = 1:3
            ax = subplot(1, 3, ai);
            vrijednosti = podaci.BestFitness(strcmp(podaci.Algorithm, algos{ai}));
            med = median(vrijednosti);

            histogram(ax, vrijednosti, 10, 'FaceColor', boje{ai}, 'EdgeColor', 'w');
            hold(ax, 'on');
            plot(ax, [med med], ylim(ax), 'r-', 'LineWidth', 2);
            title(ax, [algos{ai} ' (medijan = ' num2str(med, '%.1f') ')']);
            grid(ax, 'on');
        end
        sgtitle(['Histogrami: ' p], 'Interpreter', 'none');
        exportgraphics(fig, fullfile(folder, ['histogram_' p '.png']), 'Resolution', 200);
        close(fig);
    end

    % 3. Konvergencija
    conv_prob = {'berlin52', 'kroC100', 'kroD100', 'kroE100', 'rat99', 'st70', 'Croatia50', 'vlastiti_uniform60', 'vlastiti_clustered55', 'vlastiti_circle45'};
    for pi = 1:length(conv_prob)
        p = conv_prob{pi};
        f = ['data/tsplib/' p '.tsp'];
        if ~exist(f, 'file'), f = ['data/generated/' p '.tsp']; end
        if ~exist(f, 'file'), f = ['data/tsplib/' p '_EUC2D.tsp']; end
        if ~exist(f, 'file'), f = ['data/tsplib/' strtok(p, '_') '.tsp']; end
        if ~exist(f, 'file'), continue; end

        [koord, ~] = ucitaj_tsp(f);
        fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 700 420]);
        ax = axes(fig); hold(ax, 'on');

        rng(42);
        for ai = 1:3
            [~, ~, ~, ~, krivulja] = pokreni_ea(koord, 120, 500, 150, 0.6, 0.35, algos{ai});
            plot(ax, 1:length(krivulja), krivulja, 'Color', boje{ai}, 'LineWidth', 2, 'DisplayName', algos{ai});
        end
        xlabel(ax, 'Generacija'); ylabel(ax, 'Duljina');
        title(ax, ['Konvergencija: ' p], 'Interpreter', 'none');
        legend(ax); grid(ax, 'on');

        exportgraphics(fig, fullfile(folder, ['convergence_' p '.png']), 'Resolution', 200);
        close(fig);
    end

    % 4. Mape
    mape_prob = {'berlin52', 'kroC100', 'st70', 'Croatia50'};
    for pi = 1:length(mape_prob)
        p = mape_prob{pi};
        f = ['data/tsplib/' p '.tsp'];
        if ~exist(f, 'file'), f = ['data/generated/' p '.tsp']; end
        if ~exist(f, 'file'), continue; end

        [koord, ~] = ucitaj_tsp(f);
        rng(1);
        [~, ~, ~, ruta] = pokreni_ea(koord, 80, 300, 100, 0.6, 0.35, 'SX');

        fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 550 480]);
        ax = axes(fig); hold(ax, 'on');

        x = koord(ruta, 1); y = koord(ruta, 2);
        plot(ax, [x; x(1)], [y; y(1)], '-', 'Color', [0.2 0.5 0.9], 'LineWidth', 1.5);
        scatter(ax, koord(:,1), koord(:,2), 40, 'filled', 'MarkerFaceColor', [0.8 0.2 0.2]);

        title(ax, ['Ruta: ' p], 'Interpreter', 'none'); grid(ax, 'on');
        exportgraphics(fig, fullfile(folder, ['map_' p '.png']), 'Resolution', 200);
        close(fig);
    end

    % 5. Rangovi
    fig = figure('Visible', 'off', 'Color', 'w');
    ax = axes(fig);
    rangovi = [2.4, 1.6, 2.0];
    b = bar(ax, 1:3, rangovi, 0.5);
    for ai = 1:3, b.FaceColor = 'flat'; b.CData(ai, :) = boje{ai}; end
    ax.XTick = 1:3; ax.XTickLabel = algos; ax.YLim = [0 3.5];
    for ai = 1:3, text(ax, ai, rangovi(ai)+0.1, num2str(rangovi(ai)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold'); end
    title(ax, 'Prosjecni rangovi'); grid(ax, 'on');
    exportgraphics(fig, fullfile(folder, 'prosjecni_rangovi.png'), 'Resolution', 200);
    close(fig);

    % 6. Vremena
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 900 400]);
    ax = axes(fig); hold(ax, 'on');
    prob_list = unique(res.Problem, 'stable');
    v_cx = zeros(length(prob_list), 1); v_sx = v_cx; v_erx = v_cx;

    for pi = 1:length(prob_list)
        sub = res(strcmp(res.Problem, prob_list{pi}), :);
        for ai = 1:3
            v = sub.AvgTime(strcmp(sub.Algorithm, algos{ai}));
            if ~isempty(v)
                if ai==1, v_cx(pi)=v; elseif ai==2, v_sx(pi)=v; else, v_erx(pi)=v; end
            end
        end
    end

    plot(ax, 1:length(prob_list), v_cx, '-o', 'Color', boje{1}, 'LineWidth', 2, 'DisplayName', 'CX');
    plot(ax, 1:length(prob_list), v_sx, '-s', 'Color', boje{2}, 'LineWidth', 2, 'DisplayName', 'SX');
    plot(ax, 1:length(prob_list), v_erx, '-^', 'Color', boje{3}, 'LineWidth', 2, 'DisplayName', 'ERX');

    ax.XTick = 1:length(prob_list);
    kratki = strrep(prob_list, '_EUC2D', ''); kratki = strrep(kratki, 'vlastiti_', '');
    ax.XTickLabel = kratki; ax.TickLabelInterpreter = 'none'; ax.XTickLabelRotation = 30;
    ylabel(ax, 'Vrijeme [s]'); legend(ax, 'Location', 'northwest'); grid(ax, 'on');
    exportgraphics(fig, fullfile(folder, 'usporedba_vremena.png'), 'Resolution', 200);
    close(fig);
end

% Crtanje boxplota
function moj_boxplot(ax, vals, poz, boja)
    q1 = quantile(vals, 0.25); q2 = median(vals); q3 = quantile(vals, 0.75);
    iqr = q3 - q1;
    mn = max(min(vals), q1 - 1.5*iqr);
    mx = min(max(vals), q3 + 1.5*iqr);
    out = vals(vals < mn | vals > mx);

    sir = 0.3;
    fill(ax, [poz-sir poz+sir poz+sir poz-sir poz-sir], [q1 q1 q3 q3 q1], boja, 'FaceAlpha', 0.7);
    plot(ax, [poz-sir poz+sir], [q2 q2], 'k-', 'LineWidth', 2);
    plot(ax, [poz poz], [mn q1], 'k-'); plot(ax, [poz poz], [q3 mx], 'k-');
    plot(ax, [poz-sir/2 poz+sir/2], [mn mn], 'k-'); plot(ax, [poz-sir/2 poz+sir/2], [mx mx], 'k-');
    if ~isempty(out), scatter(ax, repmat(poz, size(out)), out, 20, '+', 'MarkerEdgeColor', boja); end
end
