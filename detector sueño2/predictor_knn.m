#### PREDICTOR KNN ####

## Este script predice el estado de una muestra de pacientes. Para ello,
## selecciona al azar `TE` (tamaño grupo entrenamiento) pacientes y utiliza sus 
## datos construir matrices para varios clasificadores KNN.
## Luego, se una prueba sobre el resto de los `TM` pacientes.
## Al hacerlo, va guardando la sensibilidad, especificidad, "totalidad" y 
## accuracy de las predicciones en cada grupo

TE = 15;        ## Tamaño grupo entrenamiento
TM = 31 - TE;   ## Numero de pacientes en cada grupo de prueba
K  = [9 11 13 15 17 21]; ## Numero de vecinos¨ a considerar en el algoritmo
Nk = length(K);

# Cargamos datos y los procesamos (si no estaban cargados ya)

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

# Construimos varias matrices para el predictor:

# 1. Matriz Aceleracion-Corazon-Estado
# 2. Matriz Aceleracion-Estado
# 3. Matriz Corazon-Estado
# 4. Matriz Corazon-ApEn_r3-Estado
# 5. Matriz Corazon-ApEn_r4-Estado
# 6. Matriz Corazon-ApEn_r5-Estado
# 7. Matriz Corazon-ApEn_r6-Estado

Nclas = 7;    # Numero de clasificadores

m_ace = [];
m_ae  = [];
m_ce  = [];
m_c3e = [];
m_c4e = [];
m_c5e = [];
m_c6e = [];

for i = ids_entrenamiento
  m = pacientes{i};
  m_ace = [m_ace ; m(:, [3 4 2])];
  m_ae  = [m_ae  ; m(:, [3 2])];
  m_ce  = [m_ce  ; m(:, [4 2])];
  m_c3e = [m_c3e ; m(:, [4 5 2])];
  m_c4e = [m_c4e ; m(:, [4 6 2])];
  m_c5e = [m_c5e ; m(:, [4 7 2])];
  m_c6e = [m_c6e ; m(:, [4 8 2])];
endfor

# En cada matriz filtramos aquellas filas que contienen celdas sin definir (-3)
m_ae  = m_ae (m_ae(:,1) >= 0, :);
m_ce  = m_ce (m_ce(:,1) >= 0, :);
m_ace = m_ace((m_ace(:,1) >= 0) & (m_ace(:,2) >= 0), :);
m_c3e = m_c3e((m_c3e(:,1) >= 0) & (m_c3e(:,2) > -3), :);
m_c4e = m_c4e((m_c4e(:,1) >= 0) & (m_c4e(:,2) > -3), :);
m_c5e = m_c5e((m_c5e(:,1) >= 0) & (m_c5e(:,2) > -3), :);
m_c6e = m_c6e((m_c6e(:,1) >= 0) & (m_c6e(:,2) > -3), :);


printf("Ejecutando algoritmo KNN para grupo de prueba:\n");
printf("%d ", ids_prueba);
printf("\n");
  
tic();

# Estadisticas de cada clasificador para el grupo, en todos los k
S  = zeros(Nk, Nclas);
E  = zeros(Nk, Nclas);
T  = zeros(Nk, Nclas);
A  = zeros(Nk, Nclas);
F1 = zeros(Nk, Nclas);

# Estadisticas de cada paciente, para cada clasificador, en todos los k
sens     = zeros(Nk, TM, Nclas);
espec    = zeros(Nk, TM, Nclas);
total    = zeros(Nk, TM, Nclas);
accuracy = zeros(Nk, TM, Nclas);
f1       = zeros(Nk, TM, Nclas);

for paciente = 1:TM
  # Obtenemos id del paciente
  id = ids_prueba(paciente);
  printf("ID paciente: %d\n", id);
  # Cargamos la matriz de informacion del paciente
  m_pac = pacientes{id};
  # Inicilizamos estado en -3 para cada clasificador
  Nvent = size(m_pac, 1);               # Numero de ventanas
  
  estados = ones(Nk, Nvent, Nclas) * (-3);        # Matriz con la salida de cada clasificador
  ms = {m_ae m_ce m_ace m_c3e m_c4e m_c5e m_c6e}; # Matrices de cada clasificador
  
  # Por cada valor de K
  for k_idx = 1:Nk
    k = K(k_idx);
    printf("k = %d...", k);
    
     # Por cada ventana de tiempo
    for i = 1:Nvent
      # Hacemos una predicción con cada matriz, siempre y cuando haya datos en la
      # ventana de tiempo analizada
      ventana = m_pac(i, :);                      # Ventana de tiempo con los datos disponibles
      vs = {ventana(3) ventana(4) ventana(3:4) ventana(4:5) ventana([4 6]) ventana([4 7]) ventana([4 8])};  # Vectores para cada clasificador
      
      # Por cada clasificador
      for j = 1:Nclas
        mat = ms{j};
        vec = vs{j};
        # Nos aseguramos de que se pueda hacer una prediccion (no hay -3 en la ventana)
        if sum(vec <= -3) == 0
          # Obtenemos los K vecinos mas cercanos
          idx = nn(mat, vec, k);
          
          # Contamos cuantos vecinos dicen 0 o 1
          ceros = sum(mat(idx, end) == 0);
          unos  = k - ceros;
          
          # Clasificamos
          estados(k_idx, i, j) = unos > ceros;
        endif
      endfor
    endfor
  
    # Obtenemos valores del polisomnografo
    labels = m_pac(:, 2);
    
    # Calculamos estadisticas para el paciente
    for clas = 1:Nclas
      [s e t accur f_uno] = estadisticas(estados(k_idx,:,clas), labels);
      sens(k_idx,paciente, clas)     = s;
      espec(k_idx,paciente, clas)    = e;
      total(k_idx,paciente, clas)    = t;
      accuracy(k_idx,paciente, clas) = accur;
      f1(k_idx, paciente, clas)      = f_uno;
    endfor
    
    printf(" listo.\n");
  endfor
  # Graficamos
  # graficar(labels, estado);
endfor

# Calculamos estadisticas para este grupo de prueba
resultados_knn = [];
for k_idx = 1:Nk
  for clas = 1:Nclas
    S(k_idx,clas) = mean(sens(k_idx,:, clas));
    E(k_idx,clas) = mean(espec(k_idx,:, clas));
    T(k_idx,clas) = mean(total(k_idx,:, clas));
    A(k_idx,clas) = mean(accuracy(k_idx,:, clas));
    F1(k_idx,clas)= mean(f1(k_idx,:, clas));
    mean(f1(k_idx,:,clas))
    resultados_knn = [resultados_knn ; S(k_idx, clas) E(k_idx, clas) T(k_idx, clas) A(k_idx, clas) F1(k_idx,clas)];
  endfor
endfor
toc();
