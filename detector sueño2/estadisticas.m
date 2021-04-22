% Devuelve sensibilidad (s), especificidad (e), total predecidos (t) y accuracy (a)
% Toma como entrada un vector de valores predecidos (p)
% y otro de valores conocidos (c) para obtener estos estadisticos
% 1 = positivo, 0 = negativo
function [s e t a f1] = estadisticas (p, c)
  vp = 0; % Verdaderos positivos
  vn = 0; % Verdaderos negativos
  fp = 0; % Falsos positivos
  fn = 0; % Falsos negativos
  sp = 0; % Observaciones para las cuales no hay prediccion

  for i = 1:length(p)
    if p(i) > -2
      if (p(i) == 1 && c(i) == 1)
        vp += 1;
      elseif (p(i) == 0 && c(i) == 0)
        vn += 1;
      elseif (p(i) == 1 && c(i) == 0)
        fp += 1;
      elseif (p(i) == 0 && c(i) == 1)
        fn += 1;
      endif
    else
      sp += 1;
    endif
  endfor
  
  if vp + fn == 0
    s = 0;
    recall = 0;
  else
    s = vp / (vp + fn);
    recall = vp / (vp + fn);
  endif
  
  if vn + fp == 0
    e = 0;
  else
    e = vn / (vn + fp);
  endif
  
  if vp + vn + fp + fn == 0
    a = 0;
  else
    a = (vp + vn) / (vp + vn + fp + fn);
  endif
  
  if vp + fp == 0
    prec = 0;
  else
    prec = vp / (vp + fp);
  endif
  
  t = (length(c) - sp) / length(c);
  
  if (prec + recall) == 0
    f1 = 0;
  else
    f1 = 2 * prec * recall / (prec + recall);
  endif

endfunction
