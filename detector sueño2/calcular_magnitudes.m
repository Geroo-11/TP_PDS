function y = calcular_magnitudes (x)
  filas=length(x(:,1));
  cols=length(x(1,:));

  y=zeros(filas,2);

  %Copiamos los tiempos de la 1era columna de x
  y(:,1) = x(:,1);
  %Calculamos la norma de la aceleracion en los tres ejes, correspondientes a
  %la segunda a cuarta columna de x
  y(:,2) = norm(x(:,2:end),2,"rows");
endfunction
