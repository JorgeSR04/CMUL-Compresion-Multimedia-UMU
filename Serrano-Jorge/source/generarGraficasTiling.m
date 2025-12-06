function generarGraficasTiling(resultados)

if ~exist('resultados', 'var')
    error('No se encuentran los datos "resultados". Ejecuta estudio_tiempos_tiling() primero.');
end

%% 2. Configuración de Gráfica Robusta
figure('Name', 'Comparativa de Tiempos', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on; box on;

% Definimos una "piscina" de marcadores disponibles
pool_marcadores = {'o', 's', '^', 'd', 'v', '>', '<', 'p', 'h', '*'};
num_series = length(resultados.nombres);

% Generamos colores distintos para todas las series
colores = lines(num_series); 

for k = 1:num_series
    % Seleccionamos marcador de forma cíclica (nunca falla por índice)
    idx_marker = mod(k-1, length(pool_marcadores)) + 1;
    simbolo = ['-', pool_marcadores{idx_marker}]; % Ej: '-o', '-s'
    
    % Extraemos los datos de esa fila
    y_data = resultados.tiempos(k, :);
    
    % Graficamos solo si no son NaN
    if ~any(isnan(y_data))
        plot(resultados.lados, y_data, ...
             simbolo, ...
             'Color', colores(k,:), ...
             'LineWidth', 2, ...
             'MarkerFaceColor', colores(k,:), ...
             'MarkerSize', 8, ...
             'DisplayName', resultados.nombres{k});
    end
end

%% 3. Decoración
xlabel('Tamaño de Imagen (NxN píxeles)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Tiempo de Compresión (segundos)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Rendimiento Temporal (Tiling) - Calidad Q' num2str(resultados.calidad)], 'FontSize', 14);

% Leyenda inteligente
legend('Location', 'northwest', 'FontSize', 10);

% Ajuste de Ejes
xticks(resultados.lados); % Forzar que aparezcan 512, 1024, etc. en el eje X
xlim([min(resultados.lados)-100, max(resultados.lados)+100]);
axis tight; % Ajusta los márgenes

disp('Gráfica generada correctamente.');