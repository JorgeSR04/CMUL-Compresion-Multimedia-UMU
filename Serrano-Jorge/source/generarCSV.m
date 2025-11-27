function generarCSV(resultados)

    % Crear directorio si no existe
    output_Results_dir = "./Results";
    if ~exist(output_Results_dir, 'dir'), mkdir(output_Results_dir); end

    fprintf('Generando archivos Excel y CSV por imagen...\n');

    % Bucle: Procesar una imagen cada vez
    for i = 1:length(resultados)
        
        % 1. Obtener el nombre de la imagen actual para el archivo
        nombre_imagen = resultados(i).nombre;
        
        % 2. Extraer los datos y asegurar que sean columnas (usando (:))
        CaliQ = resultados(i).Q(:);
        
        % Datos DEFAULT
        Def_MSE  = resultados(i).dflt.MSE(:);
        Def_RC   = resultados(i).dflt.RC(:);
        Def_SNR  = resultados(i).dflt.PSNR(:); % Usamos PSNR como SNR
        Def_SSIM = resultados(i).dflt.SSIM(:);
        
        % Datos CUSTOM
        Cust_MSE  = resultados(i).cust.MSE(:);
        Cust_RC   = resultados(i).cust.RC(:);
        Cust_SNR  = resultados(i).cust.PSNR(:);
        Cust_SSIM = resultados(i).cust.SSIM(:);
        
        % 3. Crear la tabla con el orden solicitado:
        % CaliQ | DEFAULT (4 cols) | CUSTOM (4 cols)
        T = table(CaliQ, ...
                  Def_RC, Def_MSE,Def_SNR, Def_SSIM, ...
                  Cust_RC, Cust_MSE,S Cust_SNR, Cust_SSIM);
              
        % 4. Poner nombres bonitos a las cabeceras
        T.Properties.VariableNames = {'CaliQ', ...
            'Default_MSE', 'Default_RC', 'Default_SNR', 'Default_SSIM', ...
            'Custom_MSE', 'Custom_RC', 'Custom_SNR', 'Custom_SSIM'};
        
        % 5. Guardar archivos con el nombre de la imagen
        nombre_excel = fullfile(output_Results_dir, [nombre_imagen '.xlsx']);
        nombre_csv   = fullfile(output_Results_dir, [nombre_imagen '.csv']);
        
        try
            writetable(T, nombre_excel);
            writetable(T, nombre_csv);
            fprintf('  -> Guardado: %s\n', nombre_imagen);
        catch ME
            warning('Error guardando %s: %s', nombre_imagen, ME.message);
        end
    end
    
    fprintf('=== Tablas generadas exitosamente en folder Results ===\n');

end