x=0:pi/100:2*pi; % Eje x discreto de 200 puntos
y=sin(x); % Señal sinusoidal
y2=sin(x-0.25); % Señal retardada
y3=sin(x-0.5); % Señal retardada
figure;
plot(x,y,x,y2,x,y3);