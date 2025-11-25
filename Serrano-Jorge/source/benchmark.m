% =========================================================================
% SCRIPT DE AUTOMATIZACIÓN MEJORADO: PROYECTO COMPRESIÓN IMÁGENES DCT
% =========================================================================
clear; clc; close all;

% -------------------------------------------------------------------------
% 1. CONFIGURACIÓN
% -------------------------------------------------------------------------
% Pon aquí tus imágenes .BMP (asegúrate de que existan)
lista_imagenes = {'Baboon.bmp', 'Lena.bmp'}; 

% Factores de calidad a probar (Mínimo 6 valores)
lista_caliQ = [5, 10, 25, 50, 75, 90, 100]; 

% ¿Qué calidades queremos GUARDAR físicamente para la entrega? (Pide 3)
calidades_a_guardar = [10, 50, 90]; 

% Carpeta para organizar salidas
output_dir = 'Resultados_Entraga';
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

disp('=== INICIANDO BATERÍA DE PRUEBAS ===');

% Estructura para guardar resultados numéricos
resultados = struct();

% -------------------------------------------------------------------------
% 2. BUCLE PRINCIPAL
% -------------------------------------------------------------------------
for i = 1:length(lista_imagenes)
    nombre_completo = lista_imagenes{i};
    [~, nombre_base, ext] = fileparts(nombre_completo);
    
    fprintf('\nProcesando imagen [%d/%d]: %s\n', i, length(lista_imagenes), nombre_base);
    
    % Verificar existencia
    if ~exist(nombre_completo, 'file')
        fprintf('  ERROR: No se encuentra %s. Saltando...\n', nombre_completo);
        continue;
    end
    
    % Inicializar vectores para gráficas
    vec_MSE_dflt = []; vec_RC_dflt = [];
    vec_MSE_cust = []; vec_RC_cust = [];
    
    for Q = lista_caliQ
        fprintf('  > Calidad Q=%3d... ', Q);
        
        % --- PARTE A: DEFAULT (jcom_dflt / jdes_dflt) ---
        
        % 1. Compresión
        % Genera internamente: nombre_base.huf
        RC_d = jcom_dflt(nombre_completo, Q);
        
        % 2. Descompresión
        % Lee: nombre_base.huf -> Genera: nombre_base_des_def.bmp
        [MSE_d, ~] = jdes_dflt(nombre_completo);
        
        % 3. Gestión de archivos (Renombrar y Mover)
        fichero_huf_gen = [nombre_base '.huf'];
        fichero_bmp_gen = [nombre_base '_des_def.bmp'];
        
        if ismember(Q, calidades_a_guardar)
            % Si es una calidad clave, la guardamos bien etiquetada
            movefile(fichero_huf_gen, fullfile(output_dir, [nombre_base '_Q' num2str(Q) '_Default.huf']));
            movefile(fichero_bmp_gen, fullfile(output_dir, [nombre_base '_Q' num2str(Q) '_Default.bmp']));
        else
            % Si no, borramos los temporales para no ensuciar
            delete(fichero_huf_gen);
            delete(fichero_bmp_gen);
        end
        
        % Guardar datos
        vec_MSE_dflt(end+1) = MSE_d;
        vec_RC_dflt(end+1)  = RC_d;
        
        
        % --- PARTE B: CUSTOM (jcom_custom / jdes_custom) ---
        
        % 1. Compresión Custom
        RC_c = jcom_custom(nombre_completo, Q);
        
        % 2. Descompresión Custom
        % CUIDADO: jdes_custom TAMBIÉN genera '_des_def.bmp', sobrescribiría si no hubiéramos movido el anterior
        [MSE_c, ~] = jdes_custom(nombre_completo);
        
        % 3. Gestión de archivos
        fichero_huf_gen = [nombre_base '.huf'];
        fichero_bmp_gen = [nombre_base '_des_def.bmp']; % Tus funciones usan este sufijo fijo
        
        if ismember(Q, calidades_a_guardar)
            movefile(fichero_huf_gen, fullfile(output_dir, [nombre_base '_Q' num2str(Q) '_Custom.huf']));
            movefile(fichero_bmp_gen, fullfile(output_dir, [nombre_base '_Q' num2str(Q) '_Custom.bmp']));
        else
            delete(fichero_huf_gen);
            delete(fichero_bmp_gen);
        end
        
        vec_MSE_cust(end+1) = MSE_c;
        vec_RC_cust(end+1)  = RC_c;
        
        fprintf('OK (MSE Def: %.2f | Cust: %.2f)\n', MSE_d, MSE_c);
    end
    
    % Guardar en estructura
    resultados(i).nombre = nombre_base;
    resultados(i).Q = lista_caliQ;
    resultados(i).dflt.MSE = vec_MSE_dflt;
    resultados(i).dflt.RC  = vec_RC_dflt;
    resultados(i).cust.MSE = vec_MSE_cust;
    resultados(i).cust.RC  = vec_RC_cust;
    
    % Guardado parcial por seguridad
    save(fullfile(output_dir, 'resultados_finales.mat'), 'resultados');
end

disp('=== PROCESO COMPLETADO ===');

% -------------------------------------------------------------------------
% 3. GENERACIÓN DE GRÁFICAS (Formato Memoria)
% -------------------------------------------------------------------------
for i = 1:length(resultados)
    figure('Name', resultados(i).nombre);
    
    % Gráfica Semilogarítmica: Eje Y = log(MSE), Eje X = RC (%)
    semilogy(resultados(i).dflt.RC, resultados(i).dflt.MSE, '-bo', 'LineWidth', 2, 'MarkerFaceColor', 'b');
    hold on;
    semilogy(resultados(i).cust.RC, resultados(i).cust.MSE, '-rx', 'LineWidth', 2, 'MarkerFaceColor', 'r');
    
    grid on;
    title(['Curvas R-D para: ' resultados(i).nombre]);
    xlabel('Relación de Compresión (RC %)');
    ylabel('Error Cuadrático Medio (MSE) [Escala Log]');
    legend('Huffman Default', 'Huffman Custom', 'Location', 'best');
    
    % Guardar la gráfica automáticamente
    saveas(gcf, fullfile(output_dir, ['Grafica_' resultados(i).nombre '.png']));
end