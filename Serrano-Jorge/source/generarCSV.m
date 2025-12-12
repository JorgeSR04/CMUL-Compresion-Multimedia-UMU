function generarCSV(resultados)

    % Crear directorio si no existe
    output_Results_dir = "./Results";
    if ~exist(output_Results_dir, 'dir'), mkdir(output_Results_dir); end

    fprintf('Generando tablas (CSV para LaTeX sin SSIM)...\n'); % Mensaje actualizado

    for i = 1:length(resultados)
        
        nombre_imagen = resultados(i).nombre;
        
        % 1. Extraer datos numéricos (vectores columna)
        CaliQ  = resultados(i).Q(:);
        
        % Datos DEFAULT
        D_MSE  = resultados(i).dflt.MSE(:);
        D_RC   = resultados(i).dflt.RC(:);
        D_SNR  = resultados(i).dflt.PSNR(:);
        % D_SSIM = resultados(i).dflt.SSIM(:); % SSIM ELIMINADO
        
        % Datos CUSTOM
        % C_MSE  = resultados(i).cust.MSE(:); % MSE CUSTOM ELIMINADO (No se usaba en CSV)
        C_RC   = resultados(i).cust.RC(:);
        % C_SNR  = resultados(i).cust.PSNR(:); % PSNR CUSTOM ELIMINADO (No se usaba en CSV)
        % C_SSIM = resultados(i).cust.SSIM(:); % SSIM CUSTOM ELIMINADO
        
        % ---------------------------------------------------------
        % PARTE 1: EXCEL (Comentada)
        % ---------------------------------------------------------
        % % Aquí mantenemos el separador visual y formato bonito para Excel
        % Separador = nan(length(CaliQ), 1); 
        % DatosMatrizExcel = [CaliQ, D_MSE, D_RC, D_SNR, D_SSIM, Separador, C_MSE, C_RC, C_SNR, C_SSIM];

        % Header_Fila1 = {'', 'DEFAULT', '', '', '', '', 'CUSTOM', '', '', ''};
        % Header_Fila2 = {'CaliQ', 'MSE', 'RC', 'PSNR', 'SSIM', '', 'MSE', 'RC', 'PSNR', 'SSIM'}; 
        % Encabezados = [Header_Fila1; Header_Fila2];
        
        % nombre_excel = fullfile(output_Results_dir, [nombre_imagen '.xlsx']);
        % try
        %     writecell(Encabezados, nombre_excel, 'Range', 'A1');
        %     writematrix(DatosMatrizExcel, nombre_excel, 'Range', 'A3');
        % catch ME
        %     warning('No se pudo guardar Excel (quizás está abierto): %s', ME.message);
        % end
        
        % ---------------------------------------------------------
        % PARTE 2: CSV (Específico para LaTeX)
        % ---------------------------------------------------------
        % 1. Definimos cabeceras compatibles con LaTeX (SIN SSIM).
        headers_latex = 'CaliQ,MSE,Dflt RC,Cst RC,PSNR';
        
        % 2. Matriz de datos SOLO NUMÉRICA (SIN SSIM).
        DatosMatrizCSV = [CaliQ, D_MSE, D_RC, C_RC, D_SNR];
        
        nombre_csv = fullfile(output_Results_dir, [nombre_imagen '.csv']);
        
        % 3. Escribir cabecera manual
        fid = fopen(nombre_csv, 'w');
        fprintf(fid, '%s\n', headers_latex);
        for k = 1:length(CaliQ)
          % Se eliminó el último argumento (D_SSIM) y su formato (%.4f)
          fprintf(fid, '%.0f,%.4f,%.2f,%.2f,%.4f\n', ...
          CaliQ(k), D_MSE(k), D_RC(k), C_RC(k), D_SNR(k));

          
        end
        fclose(fid);
        fprintf(' -> OK: %s (csv)\n', nombre_imagen); 
        
    end
    
    fprintf('=== Proceso finalizado ===\n');
end