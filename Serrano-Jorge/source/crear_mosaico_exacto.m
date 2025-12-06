function img_out = crear_mosaico_exacto(img_base, lado_objetivo)
    % Obtener tamaño de la base (ej. 512)
    [h, w, ~] = size(img_base);
    
    % 1. Calcular cuántas veces hay que repetir para cubrir el objetivo
    rep_filas = ceil(lado_objetivo / h);
    rep_cols  = ceil(lado_objetivo / w);
    
    % 2. Crear el mosaico gigante
    img_out = repmat(img_base, rep_filas, rep_cols, 1);
end