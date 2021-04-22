# Esta función devuelve la entropía aproximada de una secuencia de mediciones.
# `n` debe ser a lo SUMO el largo de `d`.
# Emplea apen_coc para el grueso del trabajo. 
# n: Largo de las secuencias
# r: Distancia entre cada valor de las secuencias
# d: vector de datos (vector fila)
function res = apen(n,r,d)
##  printf("apen(n = %d, r = %d, d = [ %d %d %d %d %d ]\n", n, r, d);
  res = log(apen_coc(n-1, r, d) / apen_coc(n, r, d));
endfunction
    
