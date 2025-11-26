    function generarGraficas(resultados)

    % Carpeta para organizar salidas
    output_dir = 'Graficas';
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end
    
    disp('=== Graficando ===');
    
    for i = 1:length(resultados)
        figure('Name', resultados(i).nombre);

        % Gráfica Semilogarítmica: Eje Y = log(MSE), Eje X = RC (%)
        semilogy(resultados(i).dflt.RC, resultados(i).dflt.MSE, '-bo', 'LineWidth', 2, 'MarkerFaceColor', 'b');
        hold on;
        semilogy(resultados(i).cust.RC, resultados(i).cust.MSE, '-rx', 'LineWidth', 2, 'MarkerFaceColor', 'r');

        grid on;
        title(['Curvas R-D para: ' resultados(i).nombre]);
        xlabel('Relación de Compresión (RC %)');
        ylabel('Error Cuadrático Medio (MSE) [Escala Log]');
        legend('Huffman Default', 'Huffman Custom', 'Location', 'best');

        % Guardar la gr�fica autom�ticamente
        saveas(gcf, fullfile(output_dir, ['Grafica_' resultados(i).nombre '.png']));
    end
