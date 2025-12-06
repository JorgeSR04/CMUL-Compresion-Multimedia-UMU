function quantVectorial()

% Medidas de proximidad 
%  se suelen utilizar las medidas de distorsión distancia euclediana  
% Error cuadratico medio (distancia euclediana)
% Ocasionalmenete la distorision del peor caso

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion quantmat:');
end

% Instante inicial
t=cputime;

Output.Y.DC      % Matriz de tamaño [Filas/8, Cols/8]
Output.Y.Index   % Matriz de tamaño [Filas/8, Cols/8] (Enteros 1 a 256)

Output.Cb.DC     % Matriz de tamaño [Filas/8, Cols/8]
Output.Cb.Index  % Matriz de tamaño [Filas/8, Cols/8]

Output.Cr.DC     % Matriz de tamaño [Filas/8, Cols/8]
Output.Cr.Index  % Matriz de tamaño [Filas/8, Cols/8]

% Separa las matrices bidimensionales 
%  para procesar separadamente
YXtrans=Xtrans(:,:,1);
CbXtrans=Xtrans(:,:,2);
CrXtrans=Xtrans(:,:,3);




fun=@quant88;
YXlab=blkproc(YXtrans, [8 8], fun, QY);
CbXlab=blkproc(CbXtrans, [8 8], fun, QC);
CrXlab=blkproc(CrXtrans, [8 8], fun, QC);

% Recompone  matriz de etiquetas 3-D
Xlab=cat(3,YXlab,CbXlab,CrXlab);

% Tiempo de ejecucion
e=cputime-t;

if disptext
    disp('Matriz de etiquetas obtenida');
    disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
    disp('Terminado quantmat');
end