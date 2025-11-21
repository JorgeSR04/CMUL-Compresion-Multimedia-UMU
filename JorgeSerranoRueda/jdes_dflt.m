function [MSE,RC]=jdes_dflt(fname)

% jdes_dflt: Compresion de imagenes basada en transformadas

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
    disp('Funcion jdes_dflt:');
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
nombrecomp=strcat(name,'.huf');

% -----------------------------
% Lectura del archivo comprimido
% -----------------------------
fid = fopen(nombrecomp,'r');

% Leer cabecera
caliQ = fread(fid,1,'uint16');
namp = fread(fid, 1, 'uint32');
mamp = fread(fid, 1, 'uint32');
delta_n = fread(fid,1, 'uint8');
delta_m = fread(fid,1, 'uint8');
lengthY  = fread(fid, 1, 'uint32');
lengthCb = fread(fid, 1, 'uint32');
ultlY  = fread(fid, 1, 'uint8');
ultlCb = fread(fid, 1, 'uint8');
ultlCr = fread(fid, 1, 'uint8');

% Leer el resto de los bytes comprimidos
allBytes = fread(fid, Inf, 'uint8');
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
XScanrec=DecodeScans_dflt(CodedY,CodedCb,CodedCr,[mamp namp]);

% Recupera matrices de etiquetas en orden natural
%  a partir de orden zigzag
Xlabrec=invscan(XScanrec);

% Descuantizacion de etiquetas
Xtransrec=desquantmat(Xlabrec, caliQ);

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

% Test visual
[m,n,p] = size(X);
figure('Units','pixels','Position',[100 100 n m]);
set(gca,'Position',[0 0 1 1]);
image(X);
set(gcf,'Name','Imagen original X');
figure('Units','pixels','Position',[100 100 n m]);
set(gca,'Position',[0 0 1 1]);
image(Xrec);;
set(gcf,'Name','Imagen reconstruida Xrec');


% ----------------------------------
% Guarda la imagen descomprimida
% ----------------------------------
nombre_descomp = strcat(name, '_des_def.bmp');
imwrite(Xrec, nombre_descomp, 'bmp');
disp(['Imagen descomprimida guardada como: ', nombre_descomp]);



% Tiempo de ejecucion
e=cputime-tc;

if disptext
disp('Compresion terminada');
disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
disp('Terminado jdes_dflt');
disp('--------------------------------------------------');
end