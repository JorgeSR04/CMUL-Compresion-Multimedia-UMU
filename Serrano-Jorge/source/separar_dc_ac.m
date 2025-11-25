function [DC, AC] = separar_dc_ac(scan)
    [h, w, c] = size(scan);
    DC = [];
    AC = [];
    
    % Como las tablas sse generan segun la dimension Y y las dimensiones C
    % hay que llevar cuidad de pasar el scan de Y solo y no con el resto 
    for canal = 1:c
        for i = 1:8:h
            for j = 1:8:w
                bloque = scan(i:i+7, j:j+7, canal);
                DC = [DC; bloque(1,1)];                  % Coeficiente DC
                AC = [AC; reshape(bloque, 1, [])(2:end)]; % Coeficientes AC
            end
        end
    end
end
