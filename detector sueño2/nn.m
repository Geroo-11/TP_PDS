# Devuelve `k` vecinos mas cercanos
# `m` es una matriz de N columnas y `v` es un vector de (N-1) columnas.
# La ultima columna de la matriz `m` es la etiqueta correspondiente a las
# mediciones y no se utiliza

function idx = nn(m, v, k)
  # Calculamos vector columna que contiene las distancias correspondientes de
  # cada vector de `m` a `v`. Usa norma euclideana.
  d = norm(m(:, 1:end-1) - v, 2, "rows");
  
  # Le agregamos la informacion de cada indice a d
  # Ahora tiene (indice, distancia)
  d = [[1:size(m, 1)]' d];
  
  # Ordenamos d en base a la distancia (segunda columna)
  d = sortrows(d, 2);
  
  # Devolvemos los primeros `k` indices
  idx = d(1:k, 1);
endfunction
