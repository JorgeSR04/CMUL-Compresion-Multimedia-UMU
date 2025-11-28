% =========================================================================
% SCRIPT DE AUTOMATIZACIÓN MEJORADO: PROYECTO COMPRESIÓN IMÁGENES DCT
% =========================================================================
clear; clc; close all;

input_dir = './Images';

% Verificar si el directorio existe
if ~exist(input_dir, 'dir')
    error('El directorio "%s" no existe.', input_dir);
end

% Obtener la lista de archivos .bmp en el directorio
archivos_imagen = dir(fullfile(input_dir, '*.bmp'));

% Asegurarse de que se hayan encontrado imágenes
if isempty(archivos_imagen)
    error('No se encontraron imágenes .bmp en el directorio "%s".', input_dir);
end

% -------------------------------------------------------------------------
% 1. CONFIGURACIÓN
% -------------------------------------------------------------------------
lista_imagenes = {archivos_imagen.name};

% Factores de calidad a probar
lista_caliQ = [5, 25, 50, 100, 200, 400, 800, 1600];

% ¿Qué calidades queremos GUARDAR físicamente para la entrega?
calidades_a_guardar = [5, 25, 50, 100, 200, 400, 800, 1600];

disp('=== INICIANDO BATERÍA DE PRUEBAS CON MÉTRICAS AVANZADAS ===');

% Estructura para guardar resultados numéricos
resultados = struct();

% -------------------------------------------------------------------------
% 2. BUCLE PRINCIPAL
% -------------------------------------------------------------------------
% Carpetas para organizar salidas
output_custom_dir = "./Custom";
if ~exist(output_custom_dir, 'dir'), mkdir(output_custom_dir); end
output_default_dir = "./Default";
if ~exist(output_default_dir, 'dir'), mkdir(output_default_dir); end
output_Results_dir = "./Results";
if ~exist(output_Results_dir, 'dir'), mkdir(output_Results_dir); end

for i = 1:length(lista_imagenes)
    nombre_completo = fullfile(input_dir, archivos_imagen(i).name);
    [~, nombre_base, ext] = fileparts(nombre_completo);

    fprintf('\nProcesando imagen [%d/%d]: %s\n', i, length(lista_imagenes), nombre_base);

    % Verificar existencia
    if ~exist(nombre_completo, 'file')
        fprintf('  ERROR: No se encuentra %s. Saltando...\n', nombre_completo);
        continue;
    end

    % --- Inicializar vectores para gráficas (AHORA INCLUYEN PSNR Y SSIM) ---
    vec_MSE_dflt = []; vec_RC_dflt = []; vec_PSNR_dflt = []; vec_SSIM_dflt = [];
    vec_MSE_cust = []; vec_RC_cust = []; vec_PSNR_cust = []; vec_SSIM_cust = [];

    for Q = lista_caliQ
        fprintf('  > Calidad Q=%3d... ', Q);

        % =========================================================
        % PARTE A: DEFAULT (jcom_dflt / jdes_dflt)
        % =========================================================

        % 1. Compresión
        RC_d = jcom_dflt(nombre_completo, Q);

        % 2. Descompresión
        % NUEVO: Recogemos 4 variables. Ignoramos la 2 (RC interna) y la 5 (FSIM)
        [MSE_d, ~, PSNR_d, SSIM_d] = jdes_dflt(nombre_completo);

        % 3. Gestión de archivos
        fichero_huf_gen = [nombre_base '.hud'];
        fichero_bmp_gen = [nombre_base '_des_def.bmp'];

        if ismember(Q, calidades_a_guardar)
            movefile(fichero_huf_gen, fullfile(output_default_dir, [nombre_base '_Q' num2str(Q) '_Default.hud']));
            movefile(fichero_bmp_gen, fullfile(output_default_dir, [nombre_base '_Q' num2str(Q) '_Default.bmp']));
        else
            delete(fichero_huf_gen);
            delete(fichero_bmp_gen);
        end

        % Guardar datos en vectores temporales
        
        vec_MSE_dflt(end+1)  = MSE_d;
        vec_RC_dflt(end+1)   = RC_d;
        vec_PSNR_dflt(end+1) = PSNR_d;  
        vec_SSIM_dflt(end+1) = SSIM_d; 


        % =========================================================
        % PARTE B: CUSTOM (jcom_custom / jdes_custom)
        % =========================================================

        % 1. Compresión Custom
        RC_c = jcom_custom(nombre_completo, Q);

        % 2. Descompresión Custom
        % NUEVO: Asumimos que jdes_custom también devuelve [MSE, RC, PSNR, SSIM]
        [MSE_c, ~, PSNR_c, SSIM_c] = jdes_custom(nombre_completo);

        % 3. Gestión de archivos
        fichero_huf_gen = [nombre_base '.huc'];
        fichero_bmp_gen = [nombre_base '_des_cus.bmp'];

        if ismember(Q, calidades_a_guardar)
            movefile(fichero_huf_gen, fullfile(output_custom_dir, [nombre_base '_Q' num2str(Q) '_Custom.huc']));
            movefile(fichero_bmp_gen, fullfile(output_custom_dir, [nombre_base '_Q' num2str(Q) '_Custom.bmp']));
        else
            delete(fichero_huf_gen);
            delete(fichero_bmp_gen);
        end

        vec_MSE_cust(end+1)  = MSE_c;
        vec_RC_cust(end+1)   = RC_c;
        vec_PSNR_cust(end+1) = PSNR_c; 
        vec_SSIM_cust(end+1) = SSIM_c; 

        fprintf('OK (SSIM Def: %.3f | SSIM Cust: %.3f)\n', SSIM_d, SSIM_c);
    end

    % ---------------------------------------------------------------------
    % Guardar en estructura "resultados"
    % ---------------------------------------------------------------------
    resultados(i).nombre = nombre_base;
    
    resultados(i).Q = lista_caliQ;
    
    % Datos Default
    resultados(i).dflt.MSE  = vec_MSE_dflt;
    resultados(i).dflt.RC   = vec_RC_dflt;
    resultados(i).dflt.PSNR = vec_PSNR_dflt; 
    resultados(i).dflt.SSIM = vec_SSIM_dflt; 
    
    % Datos Custom
    resultados(i).cust.MSE  = vec_MSE_cust;
    resultados(i).cust.RC   = vec_RC_cust;
    resultados(i).cust.PSNR = vec_PSNR_cust; 
    resultados(i).cust.SSIM = vec_SSIM_cust; 

    % Guardado parcial por seguridad
    save(fullfile(output_Results_dir, 'resultados_finales.mat'), 'resultados');
end



generarGraficas(resultados);
generarCSV(resultados);

disp('=== PROCESO COMPLETADO ===');