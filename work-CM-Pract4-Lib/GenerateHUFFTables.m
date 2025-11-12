function [ehuf, Bits, huffval] = GenerateHUFFTables(DC_data, AC_data)

% GenerateHUFFTables: Genera las tablas de codificación Huffman para componentes DC y AC.
%
% Entradas:
%   DC_data : Datos de coeficientes DC (matriz o vector de etiquetas)
%   AC_data : Datos de coeficientes AC (matriz o vector de etiquetas)
%
% Salidas:
%   ehuf     : Estructura con las tablas de codificación final (EHUFCO y EHUFSI)
%   Bits     : Estructura con los vectores de número de códigos por longitud (DC y AC)
%   huffval  : Estructura con los valores Huffman asociados (DC y AC)

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion GenerateHUFFTables:');
end

% Instante inicial
tc=cputime;

    % Calcula frecuencias
    DC_freq = Freq256(DC_data);
    AC_freq = Freq256(AC_data);

    % Genera tablas de especificación
    [DC_BITS, DC_HUFFVAL] = HSpecTables(DC_freq);
    [AC_BITS, AC_HUFFVAL] = HSpecTables(AC_freq);

    % Guardamos Bits y Huffval
    Bits.DC = DC_BITS;
    Bits.AC = AC_BITS;
    huffval.DC = DC_HUFFVAL;
    huffval.AC = AC_HUFFVAL;

    % Genera HUFFSIZE y HUFFCODE
    [DC_HUFFSIZE, DC_HUFFCODE] = HCodeTables(DC_BITS, DC_HUFFVAL);
    [AC_HUFFSIZE, AC_HUFFCODE] = HCodeTables(AC_BITS, AC_HUFFVAL);

    % Genera tablas de codificación final
    [DC_EHUFCO, DC_EHUFSI] = HCodingTables(DC_HUFFSIZE, DC_HUFFCODE, DC_HUFFVAL);
    [AC_EHUFCO, AC_EHUFSI] = HCodingTables(AC_HUFFSIZE, AC_HUFFCODE, AC_HUFFVAL);

    % Concatenar resultados
    ehuf.DC = [DC_EHUFCO, DC_EHUFSI];
    ehuf.AC = [AC_EHUFCO, AC_EHUFSI];
   
% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Matriz descuantizada obtenida');
    disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
    disp('Terminado GenerateHUFFTables');
end
    
end
