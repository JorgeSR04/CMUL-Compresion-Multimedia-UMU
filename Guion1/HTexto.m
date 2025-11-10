function h = HTexto(nombre);

[x, lenx] = ReadTextFile(nombre);
vals = unique(x);            % Obtiene los valores únicos
FREQS = histc(x, vals);     % Cuenta las apariciones de cada valor

P = FREQS/lenx;             %Calcular las probs de cada valor único

h = Entro(P);