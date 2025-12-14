function RC=jcom_custom(fname,caliQ)

% jcom_custom: Compresion de imagenes basada en transformadas

% Entradas:
%  fname: Un string con nombre de archivo, incluido sufijo
%         Admite BMP y JPEG, indexado y truecolor
%  caliQ: Factor de calidad (entero positivo >= 1)
%         100: calidad estandar
%         >100: menor calidad
%         <100: mayor calidad
% Salidas:
%  RC. Relación de compresion de la imagen proporcionada

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion jcom_custom:');
end

% Instante inicial
tc=cputime;

% Lee archivo de imagen
% Convierte a espacio de color YCbCr
% Amplia dimensiones a multiplos de 8
%  X: Matriz original de la imagen en espacio RGB
%  Xamp: Matriz ampliada de la imagen en espacio YCbCr
[X, Xamp, tipo, m, n, mamp, namp, TO]=imlee(fname);

% Diferencias entre dimensiones originales y ampliadas
delta_m = mamp - m;  % filas agregadas
delta_n = namp - n;  % columnas agregadas

%Calculamos el tamaño de la imagen truecolor para posteriomente calcular RC
lenx = m * n * 3;

% Calcula DCT bidimensional en bloques de 8 x 8 pixeles
Xtrans = imdct(Xamp);

% Cuantizacion de coeficientes coefiecentes enteros


Xlab=quantmat(Xtrans, caliQ);

%Xlab = quantmat_zonal(Xtrans);  - Cambiado segun la estrategia aplicada
%Xlab = quantmat_n_largest(Xtrans);

% Genera un scan por cada componente de color
%  Cada scan es una matriz mamp x namp
%  Cada bloque se reordena en zigzag
XScan=scan(Xlab);

% Codifica los tres scans, usando Huffman estadistico
[CodedY,CodedCb,CodedCr, Bits, Huffval]=EncodeCustomScans(XScan);

[sbytesY, ultlY]=bits2bytes(CodedY);
[sbytesCb, ultlCb]=bits2bytes(CodedCb);
[sbytesCr, ultlCr]=bits2bytes(CodedCr);

% Concatenar todos los bytes en un solo array
allBytes = [sbytesY; sbytesCb; sbytesCr];

lengths.Y  = length(sbytesY);
lengths.Cb = length(sbytesCb);
lengths.Cr = length(sbytesCr);

% Genera nombre archivo comprimido <fname>.huf
[pathstr,name,ext] = fileparts(fname);
nombrecomp=strcat(name,'.huc');

fid = fopen(nombrecomp,'w');

%% === CABECERA: Dimensiones y calidad ===
fwrite(fid, caliQ,   'uint16');
fwrite(fid, namp,    'uint32');
fwrite(fid, mamp,    'uint32');
fwrite(fid, delta_n, 'uint8');
fwrite(fid, delta_m, 'uint8');

%% === LUMINANCIA (Y) ===
% Longitud
fwrite(fid, lengths.Y, 'uint32');

% Bits
fwrite(fid, length(Bits.Y.DC), 'uint8');
fwrite(fid, Bits.Y.DC, 'uint8');
fwrite(fid, length(Bits.Y.AC), 'uint8');
fwrite(fid, Bits.Y.AC, 'uint8');

% Huffval
fwrite(fid, length(Huffval.Y.DC), 'uint8');
fwrite(fid, Huffval.Y.DC, 'uint8');
fwrite(fid, length(Huffval.Y.AC), 'uint8');
fwrite(fid, Huffval.Y.AC, 'uint8');

% Últimos valores
fwrite(fid, ultlY, 'uint8');

%% === CROMINANCIA (Cb y Cr) ===
% Longitud
fwrite(fid, lengths.Cb, 'uint32');

% Bits
fwrite(fid, length(Bits.C.DC), 'uint8');
fwrite(fid, Bits.C.DC, 'uint8');
fwrite(fid, length(Bits.C.AC), 'uint8');
fwrite(fid, Bits.C.AC, 'uint8');

% Huffval
fwrite(fid, length(Huffval.C.DC), 'uint8');
fwrite(fid, Huffval.C.DC, 'uint8');
fwrite(fid, length(Huffval.C.AC), 'uint8');
fwrite(fid, Huffval.C.AC, 'uint8');

% Últimos valores
fwrite(fid, ultlCb, 'uint8');
fwrite(fid, ultlCr, 'uint8');


% Todos los datos codificados
fwrite(fid,allBytes,'uint8'); % Mensaje comprimido y segmentado.
fclose(fid);

% --------- Calculo de FC ---------
% Como estamos usando las tablas por defecto de jpeg no necesitamos
% inculir todas las cabeceras de huffman

TO=lenx; % Longitud del fichero original.
TDatos = numel(allBytes);  % número total de bytes
TC = TDatos;
% Mostrar la(s) Relacion(es) de compresión.
RC= 100*(TO-TC)/TO; % TASA (rate) de compresión.


disp('-----------------');
disp(sprintf('%s %s', 'Archivo comprimido:', nombrecomp));
disp(sprintf('%s %2.2f %s', 'RC archivo =', RC, '%.'));


% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Compresion terminada');
    disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
    disp('Terminado jcom_custom');
    disp('--------------------------------------------------');
end