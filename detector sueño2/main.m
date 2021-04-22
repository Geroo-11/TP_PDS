# Script principal
# Invoca a paperdos y predictor_knn para obtener una tabla con la sensibilidad,
# especificidad, cobertura, accuracy y F1 de todos los clasificadores implementados,
# promediados sobre `Nexp` experimentos.

Nexp = 10;
resultados = {};

for __i = 1:Nexp
  printf("Experimento %d...\n", __i);
  paperdos
  predictor_knn
  resultados{__i} = [ resultados_paper ; resultados_knn ]
  clear ids_entrenamiento ids_prueba alfas errores;
endfor

resultados_sumados = resultados{1};
for i = 2:Nexp
  resultados_sumados += resultados{i};
endfor

resultados_promediados = resultados_sumados ./ Nexp;
