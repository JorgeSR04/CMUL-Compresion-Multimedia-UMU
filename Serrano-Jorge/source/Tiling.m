function datos_estudio = Tiling()
% ESTUDIO_TIEMPOS_TILING Ejecuta el análisis de tiempo de compresión con Tiling.
%
%   OUTPUT:
%       datos_estudio - Estructura con los siguientes campos:
%           .nombres      : Celda con los nombres de las series (leyenda).
%           .lados        : Vector con los tamaños de lado probados (Eje X).
%           .tiempos      : Matriz (nImagenes x nTamaños) con los tiempos (Eje Y).
%           .calidad      : Factor de calidad usado.
%           .timestamp    : Fecha y hora de la ejecución.

    disp(' ');
    disp('=== INICIANDO FUNCIÓN DE ANÁLISIS DE TIEMPO (TILING) ===');

    %% 1. Configuración del Experimento
    % ------------------------------------------------
    % Configuración de archivos y rutas
    imagenes_base = {'./Images/fresas.bmp','./Images/brassica.bmp','./Images/pino.bmp','./Images/grietas.bmp'};%,'./Images/sailboat.bmp','./Images/pino.bmp', './Images/franjas.bmp'}; 
    nombres_leyenda = {'Baja Var (Fresas)','Media Var (Brassica)', 'Alta Var (Pino)','Alta Var (Grietas)'};
    
    % Tamaños a probar (Lado de la imagen cuadrada)
    lados_prueba = [512,1024,1536,2048,3076]; 
    
    % Parámetros de compresión
    caliQ = 100;
    nTest = 1; % Número de repeticiones para promediar el tiempo

    % Directorio para logs o temporales (opcional)
    output_dir = 'Mosaicos';
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end

    %% 2. Inicialización de la Estructura de Salida
    % ------------------------------------------------
    % Pre-reservamos memoria para la matriz de tiempos
    matriz_tiempos = zeros(length(imagenes_base), length(lados_prueba));
    
    % Guardamos los metadatos en la estructura desde el principio
    datos_estudio.nombres = nombres_leyenda;
    datos_estudio.lados = lados_prueba;
    datos_estudio.calidad = caliQ;
    datos_estudio.timestamp = datetime('now');
    
    %% 3. Bucle Principal de Procesamiento
    % ------------------------------------------------
    for k = 1:length(imagenes_base)
        nombre_archivo = imagenes_base{k};
        
        % Verificación de existencia
        if ~exist(nombre_archivo, 'file')
            warning('Imagen no encontrada: %s. Se rellenará con NaN.', nombre_archivo);
            matriz_tiempos(k, :) = NaN;
            continue;
        end
        
        img_base = imread(nombre_archivo);
        fprintf('--> Procesando serie: %s \n', nombres_leyenda{k});
        [~, nombre_solo, ext] = fileparts(nombre_archivo);
        for j = 1:length(lados_prueba) 
            L = lados_prueba(j);
            
            % --- A. Generación del Mosaico (Tiling) ---
            % Se asume que 'crear_mosaico_exacto' existe en el path
            try
                img_test = crear_mosaico_exacto(img_base, L);
            catch
                error('La función "crear_mosaico_exacto" no se encuentra o falló.');
            end
            
            % Guardar temporal para el compresor
            
            nombre_temp = fullfile(output_dir, sprintf('%s_%d.bmp',nombre_solo , L));

            imwrite(img_test, nombre_temp);
            
            % --- B. Medición de Tiempo (Promediado) ---
            t_acumulado = 0;
            
            % Ejecutar nTest veces para estabilizar la medida del SO
            for rep = 1:nTest
                t_inicio = tic;
                
                % Llamada al compresor (silenciando salida si es posible)
                % Nota: Asegúrate de que jcom_custom está en el path
                [~] = jcom_custom(nombre_temp, caliQ); 
                
                
                t_acumulado = t_acumulado + toc(t_inicio);
                
                % Limpieza inmediata del archivo comprimido generado (.huc)
                nombre_huc = strrep(nombre_temp, '.bmp', '.huc');
                if exist(nombre_huc, 'file'), delete(nombre_huc); end
            end
            
            t_medio = t_acumulado / nTest;
            matriz_tiempos(k, j) = t_medio;
            
            fprintf('    |-- Tamaño %dx%d: %.4f seg (Promedio de %d runs)\n', ...
                    L, L, t_medio, nTest);
        end
        
        % Limpieza del archivo temporal de imagen
        if exist(nombre_temp, 'file'), delete(nombre_temp); end
        disp('    -----------------------------------');
    end

    %% 4. Finalización y Empaquetado
    % ------------------------------------------------
    % Asignamos la matriz llena a la estructura
    datos_estudio.tiempos = matriz_tiempos;
    
    % Guardado automático de respaldo (Backup)
    save(fullfile(output_dir, 'backup_tiempos_struct.mat'), 'datos_estudio');
    
    disp('=== ESTUDIO FINALIZADO CON ÉXITO ===');
    disp(['Datos guardados en estructura y backup en: ', output_dir]);
end