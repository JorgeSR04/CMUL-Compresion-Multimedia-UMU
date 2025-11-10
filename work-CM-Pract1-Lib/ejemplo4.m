x=0:pi/100:2*pi; % Eje x discreto de 200 puntos
y=sin(x); % Señal sinusoidal
plot(x,y);
xlabel('x = 0 a 2*\pi');
ylabel('sin(x)');
title('Grafica de funcion sin(x)', 'Fontsize',12);
