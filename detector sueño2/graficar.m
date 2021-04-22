
function a= graficar (est, poly)
  subplot(2,1,1);
  stem(est);
  title('estado según polisomnografo: 1-despierto, 0-dormido');
  xlabel('tiempo'); ylabel('estado');
  
  subplot(2,1,2);
  stem(poly);
  title('estado usando aceleracion: 1-despierto, 0-dormido');
  xlabel('tiempo'); ylabel('estado');
  
endfunction
