function [accel heart psg] = cargar_datos()
  ids = [1066528;
         1360686;
         1449548;
         1455390;
         1818471;
         2598705;
         2638030;
         3509524;
         3997827;
         4018081;
         4314139;
         4426783;
         46343;
         5132496;
         5383425;
         5498603;
         5797046;
         6220552;
         759667;
         7749105;
         781756;
         8000685;
         8173033;
         8258170;
         844359;
         8530312;
         8686948;
         8692923;
         9106476;
         9618981;
         9961348];
         
  N = length(ids);
  
  base_heart = "DATASET_PROC/heart_rate/";
  base_accel = "DATASET_PROC/motion/";
  base_psg   = "DATASET_PROC/labels/";

  suffix_heart = "_heartrate.txt.proc";
  suffix_accel = "_acceleration.txt.proc";
  suffix_psg = "_labeled_sleep.txt";
  
  # Cargar datos crudos
  for i = 1:N
    id = num2str(ids(i));
    accel{i} = load([base_accel id suffix_accel]);
    heart{i} = load([base_heart id suffix_heart]);
    psg{i}   = load([base_psg   id suffix_psg]);
  endfor
endfunction
