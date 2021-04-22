printf("Cargando datos...\n");
if !(exist("accel", "var") == 1 && exist("heart", "var") == 1 && exist("psg", "var") == 1)
  tic();
  [accel heart psg] = cargar_datos();
  global accel = accel;
  global heart = heart;
  global psg = psg;
  toc();
else
  printf("Los datos ya estaban cargados :)\n");
endif

printf("Ventaneando datos...\n");
if !(exist("ys", "var") && exist("tts", "var"))
  for id = 1:31
    global ys = {};
    global tts = {};
    
    x = accel{id};

    #procesamiento para tener los pares tiempo-magnitud de la aceleraci�n
    printf("Calculo magnitudes...\n");
    ys{id} = calcular_magnitudes(x);

    #ventaneo
    printf("Ventaneo...\n");
    
    tts{id} = ventanear(ys{id}(:,1), 5);
  endfor
endif

clear x;

opts.MaxFunEvals = 400;

[x fval info output grad hess] = fminunc(@func_error, [500, 500, 500, 500, 500, 500, 500]', opts);