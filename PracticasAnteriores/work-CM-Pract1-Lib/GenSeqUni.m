function SeqMess = GenSeqUni(SeqLen,m)

% Genera una secuencia de SeqLen mensajes a partir de 
%   una fuente A de m mensajes con probabilidad uniforme

% Entradas:
% SeqLen: Longitud de la secuencia generar (entero positivo)
% m: Numero de mensajes del Alfabeto fuente

% Salidas:
% SeqMess: Secuencia aleatoria de SeqLen mensajes pertenecientes al alfabeto {0, 1, 2, ... m-1}

% El Alfabeto fuente (conjunto de m posibles mensajes) se considera que es
%   el conjunto de los enteros no-negativos entre 0 y m-1
% Para otros alfabetos sera necesario hacer la traduccion aparte

% Ejemplo de uso con alfabeto {0, 1}: GenSeqUni(10, 2)
% Ejemplo de uso con alfabeto {'a', 'b', 'c', 'espacio'}:
%   A=['a' 'b' 'c' char(32)];
%   A(1+(GenSeqUni(25, 4)))
% Ejemplo de uso con alfabeto ASCII:
%   char(GenSeqUni(25, 256))

% Control de verbosidad
disptext=0;             % Flag de verbosidad
if disptext
    tc=cputime;         % Instante inicial
    disp('--------------------------------------------------');
    disp('Funcion GenSecUni:');
end

SeqMess=unidrnd(m,1,SeqLen)-1;

% Presentacion de verbosidad
if disptext
    e=cputime-tc;       % Tiempo de ejecucion
    disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
    disp('Terminado GenSecUni');
    disp('--------------------------------------------------');
end