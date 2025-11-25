function [scod,BITS,HUFFVAL]=StCompressor(x)

FREQ = Freq256(x);  % Calculamos cuantas veces aparece cada caracter

% Generamos las tablas de specificación Bits de 1 a 16
% HUFFVAL contine los codigos ascii de los caracteres ordenados por
% frecuencia de aparicion o lo que es lo mismo ordenados por longitud de su
% codeword ascendentemente

[BITS, HUFFVAL] = HSpecTables(FREQ);

%eneramos las tablas del código HUFFCODE y HUFFSIZE a partir de BITS y HUFFVAL
% HUFFSIZE contiene las longitudes de las palabras codigo ordenadas por
% longitudes crecientes igual que HUFFVAL 
% HUFFCODE contiene las codewords en decimal ordenadas crecientemente igual
% que en HUFFVAL Y HUFFSIZE

[HUFFSIZE, HUFFCODE] = HCodeTables(BITS, HUFFVAL);

[EHUFCO, EHUFSI] = HCodingTables(HUFFSIZE, HUFFCODE, HUFFVAL);

scod = EncodeString2(x, EHUFCO, EHUFSI);
