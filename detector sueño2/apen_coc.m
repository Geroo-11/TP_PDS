# Función auxiliar empleada por apen. Calcula el valor medio de los cocientes
# de similitud de las secuencias.

function [c] = apen_coc(n,r,d)
  N = length(d);        # Longitud de la secuencia de datos
  Nseqs = N - n + 1;    # Numero de n-secuencias en d
  S = zeros(Nseqs, n);  # Matriz con las secuencias
  C = zeros(Nseqs, 1);  # Vector de cocientes. Contiene en C(i) el cociente del numero
                        # secuencias similares a S(i,:) sobre el total (Nseqs)
  
  # Construimos las secuencias
  for i = 1:Nseqs
    S(i, :) = d(i:i+n-1);
  endfor
  
  # Calculamos el vector de similitud
  for i = 1:Nseqs
    simil = 0;          # Numero de secuencias similares a la iesima.
    for j = 1:Nseqs
      dist = abs(S(i, :) - S(j, :));
      simil += all(dist < r);
    endfor
    C(i) = simil / Nseqs;
  endfor
  
  c = mean(C);
endfunction