# Devuelve un vector con los valores maximos de las ventanas de ancho `tam_vent`
# `m` es una matriz de dos columnas
#   * la primera es el tiempo de la observacion
#   * la segunda es el valor de la observacion
# `end_time` es el tiempo maximo a considerar para todas las observaciones
# Por lo tanto, tambien define el numero de ventanas a devolver
# Si no hay datos en cierta ventana de tiempo, el valor es < 0

function vents = maxvent(m, tam_vent, end_time)
    Nvent = floor(end_time / tam_vent); # Numero maximo de ventanas
    vents = ones(Nvent, 1) * (-3);
    
    # Obtenemos maximos de ventanas no solapadas de 30 segundos
    # Se itera sobre cada medicion y se guarda el maximo medido en cada ventana
    w = 0;                            # Numero de ventana actual
    w_max = -1;                       # Valor maximo de m en ventana w
    idx = 2;                          # Indice de la medicion en m
    t   = m(idx, 1);                  # Tiempo de la medicion de m
    val = m(idx, 2);                  # Valor de la medicion de m
    while t < end_time
      if t / 30 > (w + 1)             # Si forma parte de la ventana siguiente
        vents(w + 1) = w_max;         # Guardamos el maximo de la ventana
        w = floor(t / 30);            # Se avanza a la siguiente ventana
        w_max = val;                  # Se define el primer valor como el maximo
        
      else                            # Si forma parte de la ventana actual
        if val > w_max                # Se actualiza el maximo
          w_max = val;
        endif
      endif
      
      # Se avanza a la siguiente medicion
      idx += 1;
      t   = m(idx, 1);
      val = m(idx, 2);
    endwhile
endfunction