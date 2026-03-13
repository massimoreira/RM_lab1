function tau = model (xinput)

  x=xinput(1);
  n=xinput(2);
  W=xinput(3);
  m=xinput(4);

  %% Prob busy
  p = 1-(1-x)^(n-1);
  %% solve for zero
  tau = -x + (2*(1-2*p))/((1-2*p)*(W+1) + p * W * (1-(2*p)^m));
  
endfunction
