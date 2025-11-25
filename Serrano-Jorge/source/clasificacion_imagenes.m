
% --- SCRIPT PARA CLASIFICAR IMÁGENES (CON RUTA CONFIGURABLE) ---
clc; clear; close all;

% ================= CONFIGURACIÓN =================
% Escribe aquí la ruta de tu carpeta. 
% Ejemplos: 'C:\Users\Jorge\Escritorio\Imagenes' o './mi_carpeta'
% Dejala como '.' si quieres usar la carpeta actual.
ruta_imagenes = '.'; 
% =================================================


% 1. Verificar si la carpeta existe
if ~isfolder(ruta_imagenes)
    error('La ruta especificada no existe: %s', ruta_imagenes);
end

% 2. Buscar imágenes en esa ruta
exts = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif'};
archivos = [];

for i = 1:length(exts)
    % fullfile une la ruta y la extensión correctamente
    patron = fullfile(ruta_imagenes, exts{i}); 
    archivos = [archivos; dir(patron)];
end

if isempty(archivos)
    error('No se han encontrado imágenes en: %s', ruta_imagenes);
end

% Preparamos variables
nombres = {};
varianzas = [];
entropias = [];

fprintf('Leyendo imágenes desde: %s\n', ruta_imagenes);
fprintf('Procesando %d imágenes...\n\n', length(archivos));

% 3. Bucle de procesamiento
for k = 1:length(archivos)
    nombre_archivo = archivos(k).name;
    
    % IMPORTANTE: Construir la ruta completa al archivo para leerlo
    ruta_completa = fullfile(archivos(k).folder, nombre_archivo);
    
    try
        img = imread(ruta_completa);
        
        % Convertir a escala de grises si es necesario
        if size(img, 3) == 3
            img_gray = rgb2gray(img);
        else
            img_gray = img;
        end
        
        img_double = double(img_gray);
        
        % --- CÁLCULOS ---
        val_varianza = var(img_double(:));
        
        % Cálculo de entropía (requiere Image Processing Toolbox)
        % Si falla, usa la fórmula manual
        if exist('entropy', 'file')
            val_entropia = entropy(img_gray);
        else
            % 1. Convertimos a vector de dobles
            vec = double(img_gray(:));
            
            % 2. Contamos cuántas veces aparece cada valor (0 a 255)
            % 'histcounts' es estándar de MATLAB
            counts = histcounts(vec, 0:256);
            
            % 3. Calculamos la probabilidad (p)
            p = counts / sum(counts);
            
            % 4. Eliminamos probabilidades cero (porque log2(0) es infinito)
            p = p(p > 0);
            
            % 5. Fórmula de Shannon
            val_entropia = -sum(p .* log2(p));
        end
        
        % Guardar datos
        nombres{end+1, 1} = nombre_archivo;
        varianzas(end+1, 1) = val_varianza;
        entropias(end+1, 1) = val_entropia;
        
    catch ME
        warning('No se pudo leer la imagen %s. Error: %s', nombre_archivo, ME.message);
    end
end

% 4. Crear tabla y ordenar
T = table(nombres, varianzas, entropias, ...
    'VariableNames', {'Imagen', 'Varianza', 'Entropia'});

% Ordenar de menor a mayor Varianza (Menos detalle -> Más detalle)
T_ordenada = sortrows(T, 'Varianza');

% Mostrar resultados
disp('--- RESULTADOS (Ordenados por Varianza) ---');
disp(T_ordenada);