#### ALGORITMO DEL PAPER ####

## Este script predice el estado de una muestra de pacientes. Para ello,
## selecciona al azar `TE` (tamaño grupo entrenamiento) pacientes y utiliza sus 
## datos para obtener un parametro umbral que permite realizar la clasificación.
## Luego, se una prueba sobre el resto de los `TM` pacientes.
## Al hacerlo, va guardando la sensibilidad, especificidad, "totalidad" y 
## accuracy de las predicciones en cada grupo

TE = 15;     ## Tamaño grupo entrenamiento
TM = 31 - TE;## Tamaño grupo de muestra

# Cargamos los datos y los procesamos (si no estaban cargados ya)

printf("cargar_datos...\n");
if !(exist("accel", "var") == 1 && exist("heart", "var") == 1 && exist("psg", "var") == 1)
  tic();  
  [accel heart psg] = cargar_datos();
  toc();
else
  printf("Los datos ya estaban cargados :)\n");
endif

printf("procesar_datos...\n");
if !(exist("pacientes", "var") == 1)
  tic();
  pacientes = procesar_datos(accel, heart, psg);
  toc();
else
  printf("Los datos ya estaban procesados :))\n");
endif

# Realizamos los muestreos, si no se han hecho ya.
printf("Realizando muestreos...\n");
if !(exist("ids_entrenamiento") && exist("ids_prueba"))
  # Borramos los alfas y errores, porque estan desactualizados
  clear alfas;
  clear errores;
  
  ids_entrenamiento = randperm(31)(1:TE);
  
  # Un 0 si es del grupo de entrenamiento, un 1 si es del grupo de prueba
  ids = ones(31, 1);
  ids(ids_entrenamiento) = 0;
  
  ids_prueba = find(ids);
else
  printf("Los muestreos ya se habian realizado\n");
endif

# Usando el grupo de entrenamiento, usamos una funcion de minimización para
# encontrar el valor umbral que maximiza la sensibilidad y especificidad
# en el grupo de entrenamiento
printf("Buscando valor umbral...\n");
if !(exist("alfas", "var") && exist("errores", "var"))
  clear PACS_ENTRENAMIENTO;
  global PACS_ENTRENAMIENTO = pacientes(ids_entrenamiento);
  ops = optimset("fminbnd");
  opts.MaxFunEvals = 200;
  opts.TolFun = 1e-3;
  alfas = [];
  errores = [];
  tic();
  for param = [50:5:95]
    [alfa fval info output]  = fminbnd(@func_error, param, param+10, opts);
    alfas = [alfas ; alfa];
    errores = [errores ; fval];
  endfor
  toc();
else
  printf("Valor umbral ya calculado :)))\n");
endif

alfa = alfas(find(errores == min(errores)));

printf("Ejecutando algoritmo paper para grupo de prueba\n");
  
tic();

sens     = zeros(TM, 1);
espec    = zeros(TM, 1);
total    = zeros(TM, 1);
accuracy = zeros(TM, 1);
f1       = zeros(TM, 1);

for paciente = 1:TM
  # Obtenemos id del paciente
  id = ids_prueba(paciente);
  # Cargamos la matriz de informacion del paciente
  m_pac = pacientes{id};
  # Inicilizamos estado en -3
  Nvent = size(m_pac, 1);         # Numero de ventanas
  estado = ones(Nvent, 1) * (-3);
  a = m_pac(:, 3);                # aceleracion
  # Estima usando los valores de la ventana actual, las 4 anteriores y las 2
  # siguientes. No produce estimacion si falta alguno de los valores (-3).
  # Usa el valor umbral para clasificar en despierto (1) o dormido (0).
  coefs = [404 598 326 441 1408 508 350];
  for i = 5:Nvent-2
    if all(a(i-4:i+2) >= 0)   # Si todos los valores estan definidos
      estado(i) = 0.0001 * (coefs * a(i-4:i+2));
    endif
  endfor
  
  # Calculamos el percentil dado por alfa
  # Para eso ignoramos los valores sin prediccion (-3)
  sin_negs = estado(estado >= 0);
  [q] = prctile(sin_negs, alfa);
  
  # Clasificamos en base al percentil
  for i = 5:Nvent-2
    if estado(i) >= 0
      if estado(i) > q
        estado(i) = 1;
      else
        estado(i) = 0;
      endif
    endif
  endfor
  
  # Obtenemos valores del polisomnografo
  labels = m_pac(:, 2);
  
  # Calculamos estadisticas para el paciente
  [s e t accur f_uno] = estadisticas(estado, labels);
  sens(paciente)     = s;
  espec(paciente)    = e;
  total(paciente)    = t;
  accuracy(paciente) = accur;
  f1(paciente)       = f_uno;
  
  # Graficamos
  # graficar(labels, estado);
endfor

# Calculamos estadisticas para este grupo de prueba
S  = mean(sens);
E  = mean(espec);
T  = mean(total);
A  = mean(accuracy);
F1 = mean(f1);

toc();

resultados_paper = [S E T A F1]