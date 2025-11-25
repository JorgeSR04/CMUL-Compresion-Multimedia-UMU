function H = Entro(P);

% Dada una DDP discreta P, calcula su entropia H

% Entradas:
%   P: Es un vector columna conteniendo una ddp discreta
%    P tambien puede ser una matriz m x n que contiene
%       n distribuciones (una por columna) de m probabilidaes
%    Una ddp debe satisfacer axiomas de probabilidad:
%       Si su suma es menor que cero o mayor que uno, o alguna probabilidad
%       es menor que cero o mayor que uno, entonces H es 0.
%    Si hay un termino 0*log 0, contribuye a H con 0

% Salidas:
%   H: Entropia de P en bits

%   Calculamos la suma total de probabilidades
suma = sum(P);
epsilon=4*eps;
uno_p=1+epsilon;
cero_m=0-epsilon;
cero_p=0+epsilon;
%   Usamos el operador relacional |, y la función any (ver Help)
if ((suma < cero_m) | (suma > uno_p) | any(P < cero_m) | any(P > uno_p))
    H = 0;
    disp('Error en la entrada: Probabilidades no validas');
else
    H = -sum(P.*log2(P + ((P>cero_m)&(P<cero_p))));
    % Si P(i) es un poquito mayor que -0 y un poco menor que 0.000000001
    % hace P + true = P(i)+1;
    
end;
