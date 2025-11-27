function generarCSV(resultados)

    % Crear directorio si no existe
    output_Results_dir = "./Results";
    if ~exist(output_Results_dir, 'dir'), mkdir(output_Results_dir); end

    fprintf('Generando tablas Excel con formato limpio...\n');

    for i = 1:length(resultados)
        
        nombre_imagen = resultados(i).nombre;
        
        % 1. Extraer datos numéricos
        CaliQ = resultados(i).Q(:);
        
        % Datos DEFAULT
        D_MSE  = resultados(i).dflt.MSE(:);
        D_RC   = resultados(i).dflt.RC(:);
        D_SNR  = resultados(i).dflt.PSNR(:);
        D_SSIM = resultados(i).dflt.SSIM(:);
        
        % Datos CUSTOM
        C_MSE  = resultados(i).cust.MSE(:);
        C_RC   = resultados(i).cust.RC(:);
        C_SNR  = resultados(i).cust.PSNR(:);
        C_SSIM = resultados(i).cust.SSIM(:);
        
        % Creamos una columna separadora vacía (NaNs) para que haya hueco visual
        Separador = nan(length(CaliQ), 1); 
        
        % 2. Construir la Matriz de Datos Numéricos
        % Orden: Q | Def_Datos | Separador | Cust_Datos
        DatosMatriz = [CaliQ, D_MSE, D_RC, D_SNR, D_SSIM, Separador, C_MSE, C_RC, C_SNR, C_SSIM];

        % 3. Diseñar los ENCABEZADOS (Dos filas)
        
        % Fila 1: Los "Super-títulos"
        % Nota: Ponemos 'DEFAULT' y 'CUSTOM' al inicio de su bloque
        Header_Fila1 = {'', 'DEFAULT', '', '', '', '', 'CUSTOM', '', '', ''};
        
        % Fila 2: Los nombres de métricas limpios
        Header_Fila2 = {'CaliQ', 'MSE', 'RC', 'PSNR', 'SSIM', '', 'MSE', 'RC', 'PSNR', 'SSIM'};
        
        % Combinamos ambas filas en un Cell Array
        Encabezados = [Header_Fila1; Header_Fila2];
        
        % 4. Guardar en Excel
        nombre_excel = fullfile(output_Results_dir, [nombre_imagen '.xlsx']);
        
        try
            % Paso A: Escribir los encabezados (Filas 1 y 2)
            writecell(Encabezados, nombre_excel, 'Range', 'A1');
            
            % Paso B: Escribir los datos numéricos debajo (desde Fila 3)
            writematrix(DatosMatriz, nombre_excel, 'Range', 'A3');
            
            fprintf('  -> Tabla guardada: %s.xlsx\n', nombre_imagen);
            
        catch ME
            warning('Error guardando Excel de %s: %s', nombre_imagen, ME.message);
        end
        
        % (Opcional) Guardar CSV simplificado (El CSV no soporta celdas combinadas)
        % Para CSV usamos una tabla simple para que no se rompa el formato
        nombre_csv = fullfile(output_Results_dir, [nombre_imagen '.csv']);
        T_csv = table(CaliQ, D_MSE, D_RC, D_SNR, D_SSIM, C_MSE, C_RC, C_SNR, C_SSIM);
        T_csv.Properties.VariableNames = {'Q', 'Def_MSE', 'Def_RC', 'Def_PSNR', 'Def_SSIM', 'Cust_MSE', 'Cust_RC', 'Cust_PSNR', 'Cust_SSIM'};
        writetable(T_csv, nombre_csv);
        
    end
    
    fprintf('=== Proceso finalizado ===\n');
end