function [pacientes media_accel media_hr apen_hr] = procesar_datos(accel, heart, psg)
  pacientes   = {};
  media_accel = {};
  media_hr    = {};
  apen_hr     = {};
  
  for id = 1:31
    printf("Paciente %d\n", id);
    
    labels = psg{id};
    acc    = accel{id};
    hr     = heart{id};
    
    # Alineamos el inicio y fin de todas las ventanas
    end_time = labels(end, 1);
    # Obtenemos el ultimo tiempo que incluye datos de psg, accel y heart
    if acc(end,1) < end_time
      end_time = acc(end, 1);
    endif
    
    if hr(end, 1) < end_time
      end_time = hr(end, 1);
    endif
  
    Nvent = floor(end_time / 30); # Numero maximo de ventanas de 30 segundos
    
    # Calculamos conteos de actividad (maximos de ventanas de 30)
    # Tambien guardamos la media aritmetica.
    mag = calcular_magnitudes(acc);
    media_accel{id} = mean(mag(:,2));
    actividad_acc = maxvent(mag, 30, end_time);
    
    # Calculamos maximos de HR en ventanas de 30
    # Tambien guardamos media aritmetica
    media_hr{id}  = mean(hr(:,2));
    actividad_hr  = maxvent(hr, 30, end_time);
    
    # Calculamos entropia aproximada de HR en ventanas de 60 segundos
    # Usamos secuencias de 3, 4 y 5 mediciones y una distancia minima de 2
    # El numero de datos totales no puede ser menor a 10
    apen_hr3 = apen_vent(heart{id}, 3, 10, 30, 2, end_time);
    apen_hr4 = apen_vent(heart{id}, 4, 10, 30, 2, end_time);
    apen_hr5 = apen_vent(heart{id}, 5, 10, 30, 2, end_time);
    apen_hr6 = apen_vent(heart{id}, 5, 10, 30, 2, end_time);
    
    # Normalizamos etiquetas (para que sean solo 0 o 1)
    for i=1:size(labels, 1)
      if (labels(i,2) > 0 )
        labels(i,2) = 0;
      else
        labels(i,2) = 1;
      endif
    endfor
    
    # Normalizamos el ritmo cardiaco y la aceleracion usando media
    # aritmetica. Ignoramos valores desconocidos (-1)
    acc_nonulos = actividad_acc >= 0;
    hr_nonulos  = actividad_hr >= 0;
    actividad_acc(acc_nonulos) = actividad_acc(acc_nonulos) ./ media_accel{id};
    actividad_hr(hr_nonulos)  = actividad_hr(hr_nonulos)    ./ media_hr{id};
    
    # Se crea la matriz de datos del paciente
    m = [ labels(1:Nvent,:) actividad_acc actividad_hr apen_hr3 apen_hr4 apen_hr5 apen_hr6];
    
    pacientes{id} = m;
  endfor
endfunction