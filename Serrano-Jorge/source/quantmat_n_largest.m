function Xlab = quantmat_n_largest(Xtrans)

    % Dada una matriz transformada Xtrans, aplica codificación por UMBRAL (N-Mayores).
    % A diferencia de la Zonal, esta función procesa CADA BLOQUE individualmente,
    % seleccionando los N coeficientes con mayor magnitud en ese bloque específico.
    
    disptext = 1; 
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion quantmat_n_largest (N-Mayores por bloque):');
    end
    
    % Instante inicial
    t = cputime;
    
    % Separa canales
    YXtrans  = Xtrans(:,:,1);
    CbXtrans = Xtrans(:,:,2);
    CrXtrans = Xtrans(:,:,3);
    
    [Filas, Cols] = size(YXtrans);
    
    % -------------------------------------------------------------------------
    % PARÁMETROS N (Coeficientes a mantener)
    % -------------------------------------------------------------------------
    NumKeep_Y = 10;  % Luminancia: Guardamos los 20 más fuertes de cada bloque
    NumKeep_C = 5;  % Crominancia: Guardamos los 10 más fuertes
    
    % -------------------------------------------------------------------------
    % 1. PROCESAMIENTO LUMINANCIA (Y)
    % -------------------------------------------------------------------------
    % Convertimos a columnas (Cada columna es un bloque de 64 pixeles)
    cols_Y = im2col(YXtrans, [8 8], 'distinct');
    
    % 1. Calculamos magnitud (valor absoluto) para ordenar
    abs_cols_Y = abs(cols_Y);
    
    % 2. Ordenamos CADA COLUMNA independientemente de mayor a menor
    %    sort_idx contiene la posición original de los valores más altos
    [~, sort_idx_Y] = sort(abs_cols_Y, 1, 'descend');
    
    % 3. Crear máscara binaria dinámica
    mask_Y = zeros(size(cols_Y));
    
    % 4. Rellenar con 1 las posiciones de los Top-N
    %    Iteramos desde 1 hasta N para marcar esas posiciones en cada columna
    %    Usamos indexado lineal para velocidad
    num_bloques = size(cols_Y, 2);
    for k = 1:NumKeep_Y
        % Obtenemos la fila correspondiente al k-ésimo mayor valor de cada bloque
        filas = sort_idx_Y(k, :); 
        % Convertimos (fila, columna) a índice lineal
        indices_lineales = sub2ind(size(cols_Y), filas, 1:num_bloques);
        mask_Y(indices_lineales) = 1;
    end
    
    % *Nota: No forzamos el DC aquí porque si es el más grande, saldrá solo.
    
    % 5. Aplicar máscara y reconstruir imagen
    cols_Y_procesadas = cols_Y .* mask_Y;
    YXlab = col2im(cols_Y_procesadas, [8 8], [Filas, Cols], 'distinct');
    YXlab = round(YXlab); % Redondear para entropía
    
    
    % -------------------------------------------------------------------------
    % 2. PROCESAMIENTO CROMINANCIA (Cb y Cr)
    % -------------------------------------------------------------------------
    % Función auxiliar local para no repetir código (definida abajo)
    CbXlab = procesar_canal_n_mayores(CbXtrans, NumKeep_C);
    CrXlab = procesar_canal_n_mayores(CrXtrans, NumKeep_C);
    
    
    % -------------------------------------------------------------------------
    % SALIDA
    % -------------------------------------------------------------------------
    Xlab = cat(3, YXlab, CbXlab, CrXlab);
    
    e = cputime - t;
    if disptext
        fprintf('N-Mayores aplicado (Y=%d, C=%d por bloque)\n', NumKeep_Y, NumKeep_C);
        fprintf('%s %1.6f\n', 'Tiempo de CPU:', e);
        disp('Terminado quantmat_n_largest');
    end

end

% --- SUBFUNCIÓN AUXILIAR PARA CROMINANCIAS ---
function CanalLab = procesar_canal_n_mayores(CanalTrans, N)
    [Filas, Cols] = size(CanalTrans);
    
    % De bloques a columnas
    cols = im2col(CanalTrans, [8 8], 'distinct');
    
    % Ordenar magnitudes
    [~, sort_idx] = sort(abs(cols), 1, 'descend');
    
    % Crear máscara
    mask = zeros(size(cols));
    num_bloques = size(cols, 2);
    
    for k = 1:N
        filas = sort_idx(k, :);
        indices_lineales = sub2ind(size(cols), filas, 1:num_bloques);
        mask(indices_lineales) = 1;
    end
    
    % Aplicar y reconstruir
    cols_proc = cols .* mask;
    img_rec = col2im(cols_proc, [8 8], [Filas, Cols], 'distinct');
    CanalLab = round(img_rec);
end