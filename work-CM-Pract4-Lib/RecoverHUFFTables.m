function huffDec  = RecoverHUFFTables(Bits, huffval)

% RecoverHUFFTables: Reconstruye las tablas de decodificación Huffman para componentes DC y AC.
%
% Entradas:
%   Bits     : Estructura con los vectores de número de códigos por longitud (DC y AC)
%   huffval  : Estructura con los valores Huffman asociados (DC y AC)
%
% Salidas:
%   huffDec  : Estructura con las tablas de decodificación Huffman, que contiene:
%              MINCODE, MAXCODE y VALPTR para DC y AC


disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion RecoverHUFFTables:');
end
    
% Instante inicial
t=cputime;

    % Genera los códigos Huffman a partir de Bits y huffval
    [DC_HUFFSIZE, DC_HUFFCODE] = HCodeTables(Bits.DC, huffval.DC);
    [AC_HUFFSIZE, AC_HUFFCODE] = HCodeTables(Bits.AC, huffval.AC);

    % Crea tablas de decodificación
    [DC_MINCODE, DC_MAXCODE, DC_VALPTR] = HDecodingTables(Bits.DC, DC_HUFFCODE);
    [AC_MINCODE, AC_MAXCODE, AC_VALPTR] = HDecodingTables(Bits.AC, AC_HUFFCODE);

    % Empaqueta todo en una estructura de salida
    huffDec.DC.MINCODE = DC_MINCODE;
    huffDec.DC.MAXCODE = DC_MAXCODE;
    huffDec.DC.VALPTR  = DC_VALPTR;

    huffDec.AC.MINCODE = AC_MINCODE;
    huffDec.AC.MAXCODE = AC_MAXCODE;
    huffDec.AC.VALPTR  = AC_VALPTR;
    
    % Tiempo de ejecucion
e=cputime-t;

if disptext
    disp('Matriz de etiquetas obtenida');
    disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
    disp('Terminado RecoverHUFFTables');
end
    
end
