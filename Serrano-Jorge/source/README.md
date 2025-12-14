# Proyecto de Compresión de Imágenes Basado en DCT

Este repositorio contiene un conjunto de scripts en MATLAB desarrollados para el estudio, implementación y análisis de técnicas de compresión de imágenes. El proyecto se centra en el uso de la Transformada Discreta del Coseno (DCT), aplicando diferentes estrategias de cuantificación y codificación para evaluar la relación entre la tasa de compresión y la calidad de la imagen reconstruida.

## Estructura de Directorios Requerida

Para el correcto funcionamiento de los scripts, es necesario mantener la siguiente estructura de carpetas en la raíz del proyecto:

- ./Images Esta carpeta debe existir y contener las imágenes en formato `.bmp` que serán procesadas por los algoritmos.

## Descripción de los Ficheros

A continuación se detalla la función y responsabilidad de cada script incluido en el proyecto, agrupados por categoría.

### Ejecución Principal y Procesamiento

- **benchmark.m**: Script principal de orquestación. Itera sobre todas las imágenes del directorio `./Images`, aplica los algoritmos de compresión con distintos factores de calidad (Q) y calcula las métricas de rendimiento (MSE, RC, PSNR, SSIM). Guarda los resultados en una estructura de datos para su posterior procesamiento.

### Estrategias de Cuantificación

- **quantmat_zonal.m**: Implementa la estrategia de Codificación Zonal. Calcula la varianza de cada frecuencia a nivel global de la imagen y genera una máscara fija que conserva únicamente los coeficientes más relevantes (por ejemplo, los 20 con mayor varianza para la luminancia), anulando el resto.

- **quantmat_n_largest.m**: Implementa la estrategia de Codificación por Umbral (N-Mayores). Procesa cada bloque de 8x8 individualmente, seleccionando y conservando dinámicamente los N coeficientes con mayor magnitud dentro de ese bloque específico.

### Análisis y Estudios Específicos

- **clasificacion_imagenes.m**: Calcula la varianza y la entropía de las imágenes de entrada para clasificarlas según su complejidad (Baja, Media, Alta).

- **Tiling.m**: Realiza un estudio de rendimiento temporal. Mide el tiempo de CPU necesario para comprimir una imagen a medida que se escala su resolución mediante la técnica de mosaico (tiling). Genera datos para evaluar la escalabilidad computacional del algoritmo.

### Generación de Resultados y Gráficas

- **generarGraficas.m**: Genera curvas de Tasa-Distorsión (R-D) individuales para cada imagen procesada, enfrentando el Error Cuadrático Medio (MSE) contra la Relación de Compresión (RC).

- **generarGraficasUnificada.m**: Genera una única gráfica consolidada que superpone las curvas R-D de todas las imágenes, permitiendo una comparación global del rendimiento del compresor.

- **generarGraficasTiling.m**: Crea gráficas específicas para el estudio de tiempos generado por `Tiling.m`, agrupando las líneas de tendencia según la varianza de la imagen (Alta, Media, Baja).

- **generarCSV.m**: Exporta los resultados numéricos almacenados en la estructura de MATLAB a archivos `.csv` con formato compatible para tablas de LaTeX.

### Herramientas Auxiliares

- **crear_mosaico_exacto.m**: Función auxiliar utilizada por `Tiling.m`. Recibe una imagen base y la repite en forma de mosaico hasta alcanzar una resolución objetivo (por ejemplo, 2048x2048 píxeles) para las pruebas de carga.

## Instrucciones de Uso

1. **Preparación del entorno**: Asegúrese de que las imágenes de prueba (formato `.bmp`) se encuentran en la carpeta `./Images`.

2. **Obtención de métricas**: Ejecute el script `benchmark.m`. Esto procesará las imágenes y generará el archivo de resultados principal.

3. **Visualización de datos**:
    - Ejecute `generarGraficas(resultados)` para obtener las curvas individuales.
    - Ejecute `generarGraficasUnificada(resultados)` para obtener la comparativa global.
    - Ejecute `generarCSV(resultados)` para exportar los datos numéricos.

4. **Estudio de tiempos**: Para analizar la eficiencia temporal, ejecute primero `Tiling.m` y posteriormente `generarGraficasTiling(datos_estudio)` para visualizar los resultados.
