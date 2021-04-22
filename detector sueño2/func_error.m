# Esta función devuelve el error de aplicar la prediccion sobre el grupo de prueba
# Toma como parametro un valor umbral `alfa`. Debe existir una variable global
# `PACS_ENTRENAMIENTO` que contenga los datos de los pacientes del grupo
# de entrenamiento.
function err = func_error(alfa)
  global PACS_ENTRENAMIENTO;
  
  # Coeficientes de la fórmula
  coefs = [404 598 326 441 1408 508 350];
  
  # Calculamos el estadisticas de cada paciente
  Npacs = length(PACS_ENTRENAMIENTO);
  sens = zeros(Npacs, 1);
  espec = zeros(Npacs, 1);
  for p = 1:Npacs
    a = PACS_ENTRENAMIENTO{p}(:, 3);
    l = PACS_ENTRENAMIENTO{p}(:, 2);
    Nvent = length(l);
    estado = ones(Nvent, 1) * (-1);
    # Estima usando los valores de la ventana actual, las 4 anteriores y las 2
    # siguientes. No produce estimacion si falta alguno de los valores (-1).
    # Usa el valor umbral para clasificar en despierto (1) o dormido (0).
    for i = 5:Nvent-2
      if all(a(i-4:i+2) >= 0)   # Si todos los valores estan definidos
        estado(i) = 0.0001 * (coefs * a(i-4:i+2));
      endif
    endfor
    
    # Calculamos el percentil dado por alfa
    sin_negs = estado(estado >= 0);
    [q] = prctile(sin_negs, [alfa]);
    
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

    [s e t a f1] = estadisticas(estado, l);
##    sens(p)  = s;
##    espec(p) = e;
  endfor
##  err = 2 - (mean(sens) + mean(espec))
    err = 1 - f1
endfunction