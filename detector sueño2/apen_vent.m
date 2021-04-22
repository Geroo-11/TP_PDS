# Esta función devuelve el valor de entropía aproximado (computado por apen.m),
# en ventanas de `tam_vent` segundos. No hay valor de entropía para la ventana si esta
# contiene menos de `min_med` mediciones puntuales.
# `m` es una matriz con el tiempo y la medicion (2 columnas)
# `end_time` es el tiempo final a considerar para tomar mediciones
# Por lo tanto, tambien define el numero de ventanas a devolver
function vents = apen_vent (m, r, min_med, tam_vent, nro_vent, end_time)
  Nvent = floor(end_time / tam_vent); # Numero maximo de ventanas
  vents = ones(Nvent, 1) * (-3);
  
  # Obtenemos maximos de ventanas no solapadas de 30 segundos
  # Se itera sobre cada medicion y se guarda el ApEn en cada ventana
  w = 0;                            # Numero de ventana actual
  idx = 1;                          # Indice de la medicion en m
  idx_start = 1;                    # Indice de la primer medicion en m
  t   = m(idx, 1);                  # Tiempo de la medicion de m
  val = m(idx, 2);                  # Valor de la medicion de m
  while t < end_time && idx <= Nvent
    t   = m(idx, 1);
    val = m(idx, 2);
    if t / tam_vent > (w + nro_vent)       # Si forma parte de la ventana siguiente
      # Se guarda el ApEn de la ventana actual solo si las mediciones son mayores
      # a min_med
      if idx - idx_start >= min_med
##        m(idx_start:idx-1,:)
        if w + nro_vent > Nvent
          printf("Aca"\n);
          vents(w+1:w+nro_vent-1) = apen(min_med, r, m(idx_start:idx-1,2)');
        else
          vents(w+1:w+nro_vent) = apen(min_med, r, m(idx_start:idx-1,2)');
        endif
      endif
      idx_start = idx;              # Se marca este idx como el inicio de la ventana siguiente
      w = floor(t / 30);            # Se avanza a la siguiente ventana
    endif                           # Si forma parte de la ventana actual, no se hace nada
    
    # Se avanza a la siguiente medicion
    idx += 1;
  endwhile
endfunction
