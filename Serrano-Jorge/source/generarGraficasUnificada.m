function generarGraficasUnificada(resultados)

    % Carpeta para organizar salidas
    output_dir = './Mayores/Graficas';
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    disp('=== Graficando (Unificado con Esquema Único de Línea) ===');
    
    num_resultados = length(resultados);
    
    % --- Definir la Paleta y Marcadores ---
    
    % Generar una paleta de colores que sea lo suficientemente grande para 2 * N curvas
    % Usamos hsv para obtener un buen rango de tonos.
    num_curvas_totales = num_resultados * 2;
    colores = hsv(num_curvas_totales + 1); % +1 para evitar el primer color que puede ser muy similar al último
    
    % Definir un conjunto de marcadores distintos para rotar
    marcadores = {'o', 's', '^', 'd', 'p', 'h', '<', '>'}; 
    
    % Crear la figura
    figure('Name', 'Curvas R-D Consolidadas');
    hold on;
    
    leyendas = {}; 
    indice_color = 1; % Índice para recorrer la matriz de colores
    
    % Iterar sobre todos los resultados
    for i = 1:num_resultados
        
        nombre = resultados(i).nombre;
        
        % Obtener un marcador que se repite si hay más de 8 resultados
        marcador_actual = marcadores{mod(i-1, length(marcadores)) + 1};
        
        % --- 1. Curva de Huffman Default (Color único y Marcador) ---
        color_dflt = colores(indice_color, :);
        
        semilogy(resultados(i).dflt.RC, resultados(i).dflt.MSE, ...
            'LineWidth', 1.5, ...
            'Marker', marcador_actual, ...         % Usar un marcador específico para este resultado
            'MarkerFaceColor', color_dflt, ...     % Rellenar el marcador
            'Color', color_dflt, ...               % Color único 1
            'LineStyle', '-', ...                  % Línea sólida
            'DisplayName', [nombre ' - Default']);
        
        leyendas{end+1} = [nombre ' - Default'];
        indice_color = indice_color + 1;
        
        
        % --- 2. Curva de Huffman Custom (Otro color único y mismo Marcador) ---
        color_cust = colores(indice_color, :);
        
        semilogy(resultados(i).cust.RC, resultados(i).cust.MSE, ...
            'LineWidth', 1.5, ...
            'Marker', marcador_actual, ...          % Usar el mismo marcador para el par (Default/Custom)
            'MarkerFaceColor', color_cust, ...      % Rellenar el marcador con el nuevo color
            'Color', color_cust, ...                % Color único 2
            'LineStyle', '--', ...                  % Línea discontinua
            'DisplayName', [nombre ' - Custom']);
            
        leyendas{end+1} = [nombre ' - Custom'];
        indice_color = indice_color + 1;
    end
    
    % --- Configuración Final ---
    
    grid on;
    title('Curvas Tasa-Distorsión (R-D)');
    xlabel('Relación de Compresión (RC %)');
    ylabel('Error Cuadrático Medio (MSE) [Escala Log]');
    
    % Mostrar la leyenda
    legend(leyendas, 'Location', 'bestoutside', 'Interpreter', 'none'); 
    
    hold off;
    
    % Guardar la gráfica
    saveas(gcf, fullfile(output_dir, 'Grafica_RD_Consolidada_Unica.png'));
    
    disp('Gráfica R-D Consolidada (con esquema de línea único) guardada con éxito.');
end