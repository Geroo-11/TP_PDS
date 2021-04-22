function mejorado = mejorado_HR (est, HR, umbral)
  for i=1:length(est)
    #si lo tomé como despierto pero el HR es menor que 80, lo califico como dormido
    if(est(i)==1 && HR(i)>0 && HR(i)<umbral)
    est(i)=0;
    endif
  endfor
  mejorado=est;
endfunction
