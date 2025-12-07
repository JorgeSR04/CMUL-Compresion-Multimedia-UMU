function generarGraficasTiling(resultados)
% GENERARGRAFICAS_TILING_MODIFICADO Genera y guarda gráficas de rendimiento
% temporal para diferentes niveles de varianza (Alta, Media, Baja) y una combinada.

if ~exist('resultados', 'var')
    error('No se encuentran los datos "resultados". Ejecuta estudio_tiempos_tiling() primero.');
end

%% 1. Filtrado de datos por Varianza y Preparación de Datasets
% Identificamos los índices de las series para cada grupo de varianza
idx_alta = strncmp(resultados.nombres, 'Alta', 4);
idx_media = strncmp(resultados.nombres, 'Media', 5);
idx_baja = strncmp(resultados.nombres, 'Baja', 4);

% Inicializamos la estructura de datos para todas las gráficas
datasets = struct();

% --- Dataset 1: ALTA Varianza ---
datasets(1).nombre_archivo = 'Rendimiento_Tiling_Alta_Varianza';
datasets(1).titulo_grafica = ['Rendimiento Temporal (Tiling) - Alta Varianza - Calidad Q' num2str(resultados.calidad)];
datasets(1).nombres = resultados.nombres(idx_alta);
datasets(1).tiempos = resultados.tiempos(idx_alta, :);
datasets(1).lados = resultados.lados;

% --- Dataset 2: MEDIA Varianza ---
datasets(2).nombre_archivo = 'Rendimiento_Tiling_Media_Varianza';
datasets(2).titulo_grafica = ['Rendimiento Temporal (Tiling) - Media Varianza - Calidad Q' num2str(resultados.calidad)];
datasets(2).nombres = resultados.nombres(idx_media);
datasets(2).tiempos = resultados.tiempos(idx_media, :);
datasets(2).lados = resultados.lados;

% --- Dataset 3: BAJA Varianza ---
datasets(3).nombre_archivo = 'Rendimiento_Tiling_Baja_Varianza';
datasets(3).titulo_grafica = ['Rendimiento Temporal (Tiling) - Baja Varianza - Calidad Q' num2str(resultados.calidad)];
datasets(3).nombres = resultados.nombres(idx_baja);
datasets(3).tiempos = resultados.tiempos(idx_baja, :);
datasets(3).lados = resultados.lados;

% --- Dataset 4: COMBINADO (Todos los Resultados) ---
datasets(4).nombre_archivo = 'Rendimiento_Tiling_Combinado_Todos';
datasets(4).titulo_grafica = ['Rendimiento Temporal (Tiling) - Todos los Resultados - Calidad Q' num2str(resultados.calidad)];
datasets(4).nombres = resultados.nombres; % Todos los nombres
datasets(4).tiempos = resultados.tiempos; % Todos los tiempos
datasets(4).lados = resultados.lados;


%% 2. Generación y Guardado de Gráficas
fprintf('Iniciando la generación de %d gráficas (3 por varianza + 1 combinada)...\n', length(datasets));

for i = 1:length(datasets)
    % Verificamos si hay datos en este grupo antes de graficar
    if ~isempty(datasets(i).nombres)
        generarYGuardarGrafica(datasets(i));
    else
        warning('No se encontraron series para el grupo: %s. Gráfica omitida.', datasets(i).nombre_archivo);
    end
end

disp('Proceso de generación y guardado de las 4 gráficas completado.');

end % Fin de la función principal


%% Subfunción para generar y guardar una gráfica (NO MODIFICADA)
function generarYGuardarGrafica(data)

    % 2. Configuración de Gráfica
    fig = figure('Name', data.titulo_grafica, 'Color', 'w', 'Position', [100, 100, 800, 600]);
    hold on; grid on; box on;

    % Definición de marcadores y colores (igual que tu script original)
    pool_marcadores = {'o', 's', '^', 'd', 'v', '>', '<', 'p', 'h', '*'};
    num_series = length(data.nombres);
    colores = lines(num_series);

    for k = 1:num_series
        % Seleccionamos marcador de forma cíclica
        idx_marker = mod(k-1, length(pool_marcadores)) + 1;
        simbolo = ['-', pool_marcadores{idx_marker}];
        
        % Extraemos los datos de esa fila
        y_data = data.tiempos(k, :);
        
        % Graficamos solo si no son NaN
        if ~any(isnan(y_data))
            plot(data.lados, y_data, ...
                simbolo, ...
                'Color', colores(k,:), ...
                'LineWidth', 2, ...
                'MarkerFaceColor', colores(k,:), ...
                'MarkerSize', 8, ...
                'DisplayName', data.nombres{k});
        end
    end

    % 3. Decoración
    xlabel('Tamaño de Imagen (NxN píxeles)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Tiempo de Compresión (segundos)', 'FontSize', 12, 'FontWeight', 'bold');
    title(data.titulo_grafica, 'FontSize', 14);

    % Leyenda inteligente
    legend('Location', 'northwest', 'FontSize', 10);

    % Ajuste de Ejes
    xticks(data.lados);
    xlim([min(data.lados)-100, max(data.lados)+100]);
    axis tight;

    % 4. Guardar la gráfica en PNG
    filename = [data.nombre_archivo '.png'];
    saveas(fig, filename);
    fprintf('Gráfica "%s" generada y guardada como "%s"\n', data.titulo_grafica, filename);
    
    close(fig); % Cerrar la figura para no saturar el entorno
end