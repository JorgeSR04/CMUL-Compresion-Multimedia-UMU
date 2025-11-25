function [mse,dmaxdifer]=testquant(fname,caliQ)
% Entradas:
% fname: Un string con nombre de archivo, incluido sufijo
% Admite BMP y JPEG, indexado y truecolor
% caliQ: Factor de calidad (entero positivo >= 1)
% Salidas:
% mse: Error cuadratico medio entre la matriz original y la matriz reconstruida
% dmaxdifer: Maxima diferencia entre pixeles homologos


%Lee la imagen almacenada en el archivo fname, obtiene una matriz
%truecolor X en el espacio de color YCbCr, y amplía dimensiones a
%múltiplos de 8 replicando las ultimas columnas o filas hasta que sea multiplo: Xamp
[X, Xamp, tipo, m, n, mamp, namp, TO] = imlee(fname);   

%Aplica DCT a la matriz ampliada Xamp, obteniendo la matriz
%transformada Xtrans
Xtrans = imdct(Xamp);

Xlab = quantmat(Xtrans,caliQ);
Xtransrec = desquantmat(Xlab,caliQ);

%Aplica iDCT a Xtrans, obteniendo una reconstrucción de la matriz
%original ampliada, Xamprec
Xamprec = imidct(Xtransrec,m,n);

% Convierte Xamprec al espacio de color RGB, reduce sus dimensiones
%a las de la imagen original X, obteniendo una matriz reconstruida
%Xrec, y archiva en BMP
[Xrec, nombrecomp] = imescribe(Xamprec,m,n, fname);

% Calculo de MSE
mse=(sum(sum(sum((double(Xrec)-double(X)).^2))))/(m*n*3);

% Test de valor de diferencias double
ddifer=abs(double(Xrec)-double(X));
dmaxdifer=max(max(max(ddifer)));

% Mostrar resultados
fprintf('Error cuadrático medio (MSE): %.6f\n', mse);
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