function TxCompressor(nombre)


[x, lenx] = ReadTextFile(nombre);  % Devuelve los caracteres leidos en formato ascii
[scod,BITS,HUFFVAL]=StCompressor(x);


% Convierte string binario scod a la matriz sbytes de bytes
% Segmenta el string scodigo en segmentos de 8 digitos
% Cada segmento (byte) se almacena en una fila de la matriz sbytes
% Si el ultimo segmento tiene longitud ultl menor que 8,
% entonces se rellena con ceros.
% Entradas:
% scod: String 1 x k char array de '0' y '1‘. No contiene espacios
% Salidas:
% sbytes: array de tipo uint8 de tamaño z x 8
% ultl: Longitud del ultimo segmento sin ceros de relleno
% Es un numero entre 1 y 8
[sbytes, ultl]=bits2bytes(scod);

% Genera nombre archivo comprimido <name>.huf
[pathstr,name,ext] = fileparts(nombre);
nombrecomp=strcat(name,'.huf');


ulenBITS=uint8(length(BITS)); % Nº de filas de BITS
uBITS=uint8(BITS); % Nº de palabras codigo de cada longitud
ulenHUFFVAL=uint8(length(HUFFVAL));% Nº de filas de HUFFVAL
uHUFFVAL=uint8(HUFFVAL); % Mensajes ordenados por long. de palabra
ulensbytes=uint32(length(sbytes)); % Longitud de sbytes
uultl=uint8(ultl); % Longitud de ultimo segmento de sbytes
usbytes=sbytes; % Entrada comprimida y segmentada. Ya esta en uint8

fid = fopen(nombrecomp,'w');
fwrite(fid,ulenBITS,'uint8'); % Nº de filas de BITS
fwrite(fid,uBITS,'uint8'); % Nº de palabras codigo de cada longitud
fwrite(fid,ulenHUFFVAL,'uint8'); % Nº de filas de HUFFVAL
fwrite(fid,uHUFFVAL,'uint8'); % Mensajes ordenados por long. de palabra
fwrite(fid,ulensbytes,'uint32'); % % Longitud de sbytes. Ocupa 4 bytes
fwrite(fid,uultl,'uint8'); % Longitud de ultimo segmento de sbytes
fwrite(fid,usbytes,'uint8'); % Mensaje comprimido y segmentado.
fclose(fid);



TO=lenx; % Longitud del fichero original.
% TCabecera incluye uBITS,ulenBITS,uHUFFVAL,ulenHUFFVAL:
TCabecera=length(BITS)+1+length(HUFFVAL)+1;
% TDatos incluye ulensbytes,uultlon,usbytes
TDatos=4+1+length(sbytes);
TC=TCabecera+TDatos; % Tamaño del fichero comprimido
% Mostrar la(s) Relacion(es) de compresión.
RCfil= 100*(TO-TC)/TO; % TASA (rate) de compresión.
% COMPLETA este código para que muestre también:
% - Factor (factor) de compresión.
FC = lenx / TC;
% - Proporción (ratio) de compresión
RatioC = 100 * (TC / lenx);
disp('-----------------');
disp(sprintf('%s %s', 'Archivo comprimido:', nombrecomp));
disp(sprintf('%s %d %s %d', 'Tamaño original =', TO, 'Tamaño comprimido =', TC));
disp(sprintf('%s %d %s %d', 'Tamaño cabecera y codigo =', TCabecera, 'Tamaño dato=', TDatos));
disp(sprintf('%s %2.2f %s', 'RC archivo =', RCfil, '%.'));
disp(sprintf('%s %2.2f %s', 'RatioC archivo =', RatioC, '%.'));
disp(sprintf('%s %2.2f %s', 'FC archivo =', FC, '.'));

if RCfil<0
disp('El archivo original es demasiado pequeño. No se comprime.');
disp(sprintf('%s %2.2f %s','La cabecera provoca un aumento de tamaño de un ',abs(RCfil), '%.'));
end