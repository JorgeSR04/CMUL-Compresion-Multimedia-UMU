function SeqMess = GenSeqDDP(SeqLen, P)

% Genera una secuencia de SeqLen mensajes a partir de 
%   una fuente mensajes discretos con probabilidades P

% Entradas:
% SeqLen: Longitud de la secuencia generar (entero positivo)
% P: Distribucion de probabilidad discreta (vector fila de m elementos entre 0 y 1)

% Salidas:
% SeqMess: Secuencia aleatoria de SeqLen mensajes del alfabeto A={0, 1, 2, ... m-1}
%   Es un vector fila

% El Alfabeto fuente (conjunto de m posibles mensajes) se considera que es
%   el conjunto de los enteros no-negativos entre 0 y m-1
%   donde m es el nº de probabilidades en P
% Para otros alfabetos sera necesario hacer la traduccion aparte

% Ejemplo de uso con alfabeto {0, 1}: GenSeqDDP(10, [0.3 0.7]);
% Ejemplo de uso con alfabeto {'a', 'b', 'c', 'espacio'}:
%   A=['a' 'b' 'c' char(32)];
%   A(1+(GenSeqDDP(25, [0.5 0.1 0.25 0.15])))
% Ejemplo de uso con alfabeto ASCII:
%   Probabilidad de caracteres ASCII elegida:
%       De 0 a 31: p=0 (32 caracteres no imprimibles)
%       De 32 a 126: p=1 (95 imprimibles)
%       De 127 a 255: p=0 (129 caracteres ASCI extendido)
%   P=[zeros(1,32) (1/95)*ones(1,95) zeros(1,129)];
%   char(GenSeqDDP(32, P))
% Ejemplo de uso con alfabeto ASCII:
%   Probabilidad de caracteres ASCII elegida:
%       De 0 a 31: p=0 (32 caracteres no imprimibles)
%       De 32 a 32: p=0.2 (1 espacio)
%       De 97 a 122: p=0.8 (26 minusculas)
%       Resto: p=0 (otros caracteres ASCI)
%   P=[zeros(1,32) 0.2 zeros(1,64) (0.8/26)*ones(1,26) zeros(1,133)];
%   char(GenSeqDDP(32, P))

% Control de verbosidad
disptext=0;             % Flag de verbosidad
if disptext
    tc=cputime;         % Instante inicial
    disp('--------------------------------------------------');
    disp('Funcion GenSecDDP:');
end

% Prepara m+1 rangos de probabilidad de 0 a 1
m=length(P);
R=cumsum(P);
R=[0 R]; % Primer valor cero

% Genera secuencia de numeros aleatorios entre 0 y 1
x=rand(1,SeqLen); 

% Procesa secuencia por rangos de probabilidad
for i=1:m
    % Busca posiciones de elementos de x en el rango i
    j=find(x>=R(i) & x<R(i+1));
    % Construye salida poniendo elemento i-esimo de alfabeto en posiciones j
    SeqMess(j)=(i-1)*ones(size(j)); 
end

% Presentacion de verbosidad
if disptext
    e=cputime-tc;       % Tiempo de ejecucion
    disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
    disp('Terminado GenSecDDP');
    disp('--------------------------------------------------');
end