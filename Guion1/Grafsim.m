function Grafsim()
    n = 500;
    P = [1/4, 1/4, 1/4, 1/4]; % fuente equiprobable

    Hexps = zeros(1,n);
    for i = 1:n
        [~, hexp, ~] = SimulaH(i,P);
        Hexps(i) = hexp;
    end

    % Entropía teórica
    Hteor = Entro(P);

    figure;
    plot(1:n, Hexps, 'b'); hold on;
    yline(Hteor, 'r--', 'Teórica');
    xlabel('Longitud de la secuencia n');
    ylabel('Entropía (bits)');
    title('Entropía experimental vs teórica');
    legend('Experimental','Teórica');
    grid on;
end
