function [MSE,RC,PSNR, valSSIM]=jdes_custom(fname)

% jdes_custom: Compresion de imagenes basada en transformadas

% Entradas:
%  fname: Un string con nombre de archivo, incluido sufijo
%         Admite BMP y JPEG, indexado y truecolor
% Salidas:
%  MSE.
%  RC. Relación de compresion de la imagen reconstruida
% visualización de imagenes original y procesada

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion jdes_custom:');
end

% Instante inicial
tc=cputime;


%Lee la imagen almacenada en el archivo fname, obtiene una matriz para
%calcular el mse
[X, Xamp, tipo, m, n, mamp, namp, TO] = imlee(fname);

%Calculamos el tamaño de la imagen truecolor para posteriomente calcular FC
lenx = m * n * 3;

% Genera nombre archivo comprimido <fname>.huf
[pathstr,name,ext] = fileparts(fname);
nombrecomp=strcat(name,'.huc');

% -----------------------------
% LECTURA DEL ARCHIVO COMPRIMIDO
% -----------------------------

fid = fopen(nombrecomp, 'r');

%% === CABECERA: Dimensiones y calidad ===
caliQ   = fread(fid, 1, 'uint16');
namp    = fread(fid, 1, 'uint32');
mamp    = fread(fid, 1, 'uint32');
delta_n = fread(fid, 1, 'uint8');
delta_m = fread(fid, 1, 'uint8');

%% === LUMINANCIA (Y) ===
% Longitud
lengthY = fread(fid, 1, 'uint32');

% Bits
nBitsYDC = fread(fid, 1, 'uint8');
Bits.Y.DC = fread(fid, nBitsYDC, 'uint8');
nBitsYAC = fread(fid, 1, 'uint8');
Bits.Y.AC = fread(fid, nBitsYAC, 'uint8');

% Huffval
nHuffYDC = fread(fid, 1, 'uint8');
Huffval.Y.DC = fread(fid, nHuffYDC, 'uint8');
nHuffYAC = fread(fid, 1, 'uint8');
Huffval.Y.AC = fread(fid, nHuffYAC, 'uint8');

% Últimos valores
ultlY = fread(fid, 1, 'uint8');

%% === CROMINANCIA (Cb y Cr) ===
% Longitud
lengthCb = fread(fid, 1, 'uint32');

% Bits
nBitsCDC = fread(fid, 1, 'uint8');
Bits.C.DC = fread(fid, nBitsCDC, 'uint8');
nBitsCAC = fread(fid, 1, 'uint8');
Bits.C.AC = fread(fid, nBitsCAC, 'uint8');

% Huffval
nHuffCDC = fread(fid, 1, 'uint8');
Huffval.C.DC = fread(fid, nHuffCDC, 'uint8');
nHuffCAC = fread(fid, 1, 'uint8');
Huffval.C.AC = fread(fid, nHuffCAC, 'uint8');

% Últimos valores
ultlCb = fread(fid, 1, 'uint8');
ultlCr = fread(fid, 1, 'uint8');

%% === DATOS COMPRIMIDOS ===
allBytes = fread(fid, inf, 'uint8');

fclose(fid);


% Calculamos las dimensiones originales
m = mamp - delta_m;
n = namp - delta_n;

% -----------------------------
% Separar los scans según longitudes
% -----------------------------
offsetY  = 1;
offsetCb = offsetY + lengthY;
offsetCr = offsetCb + lengthCb;

sbytesY  = allBytes(offsetY : offsetY + lengthY - 1);
sbytesCb = allBytes(offsetCb : offsetCb + lengthCb - 1);
sbytesCr = allBytes(offsetCr : end);  % Cr ocupa el resto

% -----------------------------
% Convertir bytes a bits
% -----------------------------
CodedY  = bytes2bits(sbytesY, ultlY);   % Función inversa de bits2bytes
CodedCb = bytes2bits(sbytesCb, ultlCb);
CodedCr = bytes2bits(sbytesCr, ultlCr);

% Decodifica los tres Scans a partir de strings binarios
XScanrec=DecodeCustomScans(CodedY,CodedCb,CodedCr,[mamp namp],Bits,Huffval);

% Recupera matrices de etiquetas en orden natural
%  a partir de orden zigzag
Xlabrec=invscan(XScanrec);

% Descuantizacion de etiquetas

Xtransrec=desquantmat(Xlabrec, caliQ);

%Xtransrec = Xlabrec; cambiar si se usa zonal o mayores

% Calcula iDCT bidimensional en bloques de 8 x 8 pixeles
% Como resultado, reconstruye una imagen YCbCr con tamaño ampliado
Xamprec = imidct(Xtransrec,m, n);

% Convierte a espacio de color RGB
% Para ycbcr2rgb: % Intervalo [0,255]->[0,1]->[0,255]
Xrecrd=round(ycbcr2rgb(Xamprec/255)*255);
Xrec=uint8(Xrecrd);

% Repone el tamaño original
Xrec=Xrec(1:m,1:n, 1:3);

% Calculo de RC
TO=lenx; % Longitud del fichero original.
TDatos = numel(allBytes);  % número total de bytes
TC = TDatos;
% Mostrar la(s) Relacion(es) de compresión.
RC= 100*(TO-TC)/TO; % TASA (rate) de compresión.

% Calculo de MSE
MSE=(sum(sum(sum((double(Xrec)-double(X)).^2))))/(m*n*3);

% ---------------------------------------------------------
% Cálculo de PSNR, SSIM y FSIM
% ---------------------------------------------------------

% 1. Cálculo de PSNR (Peak Signal-to-Noise Ratio)
% Como la imagen es uint8, el pico máximo es 255.
if MSE > 0
    PSNR = 10 * log10((255^2) / MSE);
else
    PSNR = 99; % Si el error es 0, el PSNR es infinito. Ponemos un tope.
end

% 2. Cálculo de SSIM (Structural Similarity Index)
% Requiere Image Processing Toolbox. Compara estructura, luminancia y contraste.
% X y Xrec deben ser del mismo tipo (uint8).
try
    valSSIM = ssim(Xrec, X);
catch
    warning('No se pudo calcular SSIM (posible falta de Toolbox).');
    valSSIM = 0;
end

% Test de valor de diferencias double
ddifer=abs(double(Xrec)-double(X));
dmaxdifer=max(max(max(ddifer)));

% Mostrar resultados+
disp('-----------------');
disp(sprintf('%s %s', 'Archivo comprimido:', nombrecomp));
disp(sprintf('%s %2.2f %s', 'RC archivo =', RC, '%.'));

fprintf('Error cuadrático medio (MSE): %.6f\n', MSE);
fprintf('Diferencia máxima absoluta: %.6f\n', dmaxdifer);
fprintf('Error promedio absoluto: %.6f\n', mean(ddifer(:)));

%Test visual
%[m,n,p] = size(X);
%figure('Units','pixels','Position',[100 100 n m]);
%set(gca,'Position',[0 0 1 1]);
%image(X);
%set(gcf,'Name','Imagen original X');
%figure('Units','pixels','Position',[100 100 n m]);
%set(gca,'Position',[0 0 1 1]);
%image(Xrec);
%set(gcf,'Name','Imagen reconstruida Xrec');

% ----------------------------------
% Guarda la imagen descomprimida
% ----------------------------------
nombre_descomp = strcat(name, '_des_cus.bmp');
imwrite(Xrec, nombre_descomp, 'bmp');
disp(['Imagen descomprimida guardada como: ', nombre_descomp]);

% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Compresion terminada');
    disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
    disp('Terminado jdes_custom');
    disp('--------------------------------------------------');
end