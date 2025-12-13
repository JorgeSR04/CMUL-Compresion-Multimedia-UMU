function Xlab = quantmat_zonal(Xtrans)

    % Dada una matriz transformada Xtrans, aplica codificación ZONAL basada en varianza.
    % Selecciona los N-mayores coeficientes según la varianza global de la imagen.
    % Pone a cero el resto para aprovechar la compresión RLE/Huffman.
    
    disptext = 1; % Flag de verbosidad
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion quantmat_zonal (Selección por Varianza):');
    end
    
    % Instante inicial
    t = cputime;
    
    % Separa las matrices bidimensionales
    YXtrans  = Xtrans(:,:,1);
    CbXtrans = Xtrans(:,:,2);
    CrXtrans = Xtrans(:,:,3);
    
    % -------------------------------------------------------------------------
    % PARÁMETROS DE SELECCIÓN (UMBRAL)
    % -------------------------------------------------------------------------
    % Cantidad de coeficientes a mantener (incluyendo el DC)
    NumKeep_Y = 20;  % Luminancia: mantenemos más detalle (ej. 20 de 64)
    NumKeep_C = 5;  % Crominancia: más agresivo (ej. 10 de 64)
    
    % -------------------------------------------------------------------------
    % 1. PROCESAMIENTO DE LUMINANCIA (Y)
    % -------------------------------------------------------------------------
    % Paso A: Calcular la varianza de cada posición (0,0) a (7,7) en toda la imagen
    % Convertimos la imagen en columnas de 64 elementos (cada col es un bloque)
    cols_Y = im2col(YXtrans, [8 8], 'distinct');
    
    % Calculamos la varianza de cada fila (cada fila es una frecuencia DCT)
    varianzas_Y = var(cols_Y, 0, 2); 
    
    % Paso B: Crear la máscara
    [~, indices_ordenados] = sort(varianzas_Y, 'descend'); % Se queda con los indices originales ordenados de mayor a menor con mas varianza
    
    mask_col_Y = zeros(64, 1);
    
    % Seleccionamos los N mejores
    indices_top_Y = indices_ordenados(1:NumKeep_Y);
    mask_col_Y(indices_top_Y) = 1;
    
    % Forzamos siempre mantener el DC (índice 1)
    mask_col_Y(1) = 1; 
    
    % Convertimos la máscara lineal a 8x8
    Mascara_Base_Y = reshape(mask_col_Y, [8 8]);
    
    % Paso C: Replicar la máscara para cubrir toda la imagen original
    [Filas, Cols] = size(YXtrans);
    Mascara_Global_Y = repmat(Mascara_Base_Y, Filas/8, Cols/8);
    
    % Paso D: Aplicar máscara y redondear (Cuantización binaria)
    % Los coeficientes no seleccionados se vuelven 0 exactos.
    YXlab = round(YXtrans .* Mascara_Global_Y);
    
    
% -------------------------------------------------------------------------
    % 2. PROCESAMIENTO DE CROMINANCIAS (Cb y Cr Independientes)
    % -------------------------------------------------------------------------
    
    % --- A. PROCESAR Cb (Azul) ---
    cols_Cb = im2col(CbXtrans, [8 8], 'distinct');
    varianzas_Cb = var(cols_Cb, 0, 2);
    
    [~, indices_ordenados_Cb] = sort(varianzas_Cb, 'descend');
    
    mask_col_Cb = zeros(64, 1);
    mask_col_Cb(indices_ordenados_Cb(1:NumKeep_C)) = 1;
    mask_col_Cb(1) = 1; % Siempre salvar DC
    
    Mascara_Base_Cb = reshape(mask_col_Cb, [8 8]);
    Mascara_Global_Cb = repmat(Mascara_Base_Cb, Filas/8, Cols/8);
    
    % Aplicar máscara Cb
    CbXlab = round(CbXtrans .* Mascara_Global_Cb);
    
    
    % --- B. PROCESAR Cr (Rojo) ---
    % Hacemos exactamente lo mismo para Cr, con sus propias estadísticas
    cols_Cr = im2col(CrXtrans, [8 8], 'distinct');
    varianzas_Cr = var(cols_Cr, 0, 2); % <--- Aquí calculamos la varianza REAL de Cr
    
    [~, indices_ordenados_Cr] = sort(varianzas_Cr, 'descend');
    
    mask_col_Cr = zeros(64, 1);
    mask_col_Cr(indices_ordenados_Cr(1:NumKeep_C)) = 1; % Usamos el mismo N (NumKeep)
    mask_col_Cr(1) = 1; % Siempre salvar DC
    
    Mascara_Base_Cr = reshape(mask_col_Cr, [8 8]);
    Mascara_Global_Cr = repmat(Mascara_Base_Cr, Filas/8, Cols/8);
    
    % Aplicar máscara Cr (distinta a la de Cb)
    CrXlab = round(CrXtrans .* Mascara_Global_Cr);
    
    
    % -------------------------------------------------------------------------
    % SALIDA
    % -------------------------------------------------------------------------
    % Recompone matriz de etiquetas 3-D
    Xlab = cat(3, YXlab, CbXlab, CrXlab);
    
    % Tiempo de ejecucion
    e = cputime - t;
    
    if disptext
        fprintf('%s %1.6f\n', 'Tiempo de CPU:', e);
        disp('Terminado quantmat_zonal');
    end

end