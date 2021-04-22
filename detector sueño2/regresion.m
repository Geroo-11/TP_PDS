if !(exist("accel", "var") == 1 && exist("heart", "var") == 1 && exist("psg", "var") == 1)
  tic();
  [accel heart psg] = cargar_datos();
  toc();
else
  printf("Los datos ya estaban cargados :)\n");
endif

if !(exist("B", "var") == 1 && exist("S", "var") == 1)
  B = zeros(31, 7);
  S = zeros(31, 1);

  for id = 1:31
    tic();

    clear tt poly_data promedio estado puntaje;

    x = accel{id};

    #procesamiento para tener los pares tiempo-magnitud de la aceleraci�n
    printf("Calculo magnitudes...\n");
    y=calcular_magnitudes(x);

    #ventaneo
    printf("Ventaneo...\n");

    tt = ventanear(y(:,1), 5);

    #c�lculo del m�ximo de cada ventana
    printf("Calculo maximos de cada ventana...\n");

    maximos = 0;

    for i=1:(length(tt)-2)
      maximos(i)=max(y(tt(i):tt(i+2),2));
    endfor

    #cargamos los datos de etiquetas del polisomnografo y las convertimos para que las etiquetas sean
    #1: despierto
    #0: dormido
    printf("Carga datos polisomnografo...\n");
    poly_data = psg{id};

    % Normalizamos los datos del polisomnografo para tener dos etiquetas unicamente:
    % 1: despierto, 0: dormido
    printf("Normalizacion datos polisomnografo...\n");
    for i=1:length(poly_data(:,2))
      if (poly_data(i,2) > 0 )
        poly_data(i,2) = 0;
      else
        poly_data(i,2) = 1;
      endif
    endfor

    % Sobremuestreo de la señal del polimnosografo para la regresion lineal
    poly_sobrem = zeros(length(maximos), 1);

    for i = 0:length(maximos) / 6 - 1
      poly_sobrem(6*i+1) = poly_data(i+1, 2);
      poly_sobrem(6*i+2) = poly_data(i+1, 2);
      poly_sobrem(6*i+3) = poly_data(i+1, 2);
      poly_sobrem(6*i+4) = poly_data(i+1, 2);
      poly_sobrem(6*i+5) = poly_data(i+1, 2);
      poly_sobrem(6*i+6) = poly_data(i+1, 2);
    endfor

    % Calculamos la X para la regresion lineal multivariable
    X = [shift(maximos, 4), 
         shift(maximos, 3),
         shift(maximos, 2),
         shift(maximos, 1),
         maximos,
         shift(maximos, -1),
         shift(maximos, -2)]' .* fliplr(tril(ones(length(maximos), 7), 2));

    % regresion
    [beta sigma r] = ols(poly_sobrem, X);
    B(id, :) = beta;
    S(id, 1) = sigma;

   
    toc();
  endfor
endif

% Sacamos un promedio de todos los coeficientes
beta = zeros(7, 1);
sigma = mean(S);

for i = 1:7
  beta(i) = mean(B(:, i));
endfor

% Hacemos la prediccion usando los coeficientes obtenidos
##
##  puntaje = zeros(length(maximos), 1);
##  puntaje(1:4) = [ maximos(1); maximos(1); maximos(1); maximos(1) ];
##  puntaje(end-1:end) = [ maximos(end); maximos(end) ];
##
##  for i=5:length(maximos)-2
##      puntaje(i) = maximos(i-4:i+2) * beta - sigma;
##  endfor

##  q = prctile(puntaje, [1:1:100]')
##  prom_puntaje = mean(puntaje);
##  media_puntaje = median(puntaje);
##
##  for i = 1:length(maximos)
##    if puntaje(i) > q(88);
##        puntaje(i) = 1;
##    else
##        puntaje(i) = 0;
##    endif
##  endfor
##
##  subplot(2, 1, 1);
##  stem(poly_sobrem);
##  subplot(2, 1, 2);
##  stem(puntaje);
##
##  [s e] = estadisticas(puntaje, poly_sobrem)


