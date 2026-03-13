%%
%%  IEEE 802.11 model - WiFi model
%%
%%  Rodolfo Oliveira - Nova Univ. of Lisbon
%%  revised & expanded by Gonçalo Moreira - 73206
%%
function main

%{
%%% modo rodas

%% number of nodes
n_start = 3;
n_step = 10;
n_max = 100;
n_vector = n_start:n_step:n_max;
%% contention window
cw_min=16;
%% stages of retransmission
m=7;

%}

%%% primeiro objetivo
n_max = 120;
n_vector = [5 10 20 40 80 120];

cw_vector = [4 8 16];
cw_min = 16;

m=12;


%% simulation time
simulation_time = 10000;%10000

%%%
%%% prinf all simulation parameters
%%%
printf("===================================================================\n");
printf(" n=%d \t CW_min=%d \t m=%d \t simulation time =%d\n", n_max, cw_min,m,simulation_time);
printf("===================================================================\n");




i=1;
j=1;
for cw_min = cw_vector
  for n = n_vector

      %print number of nodes
      printf("Number of nodes %d/%d \n",n,n_max);
      fflush(stdout);

      %% run simulation
      [s_idle(i), s_busy(i), s_coll(i), s_succ(i), s_tau(i)] = simulation(n, m, cw_min, simulation_time);

      %% run model
      [x, fval, info] = fsolve (@model, [0.5; n; cw_min; m]);
      m_idle(i) = (1-x(1))^(n);
      m_busy(i) = 1-m_idle(i);
      m_tau(i)   = x(1);
      m_succ(i) = n*x(1) *(1-x(1))^(n-1);
      m_coll(i) = 1 - m_succ(i) - m_idle(i);

      %% validation if channel probability is 100%
      m_coll(i)+m_succ(i)+m_idle(i);

      i=i+1;
  end
  s_tau_vector{j} = s_tau;
  m_tau_vector{j} = m_tau;
  s_idle_vector{j} = s_idle;
  m_idle_vector{j} = m_idle;
  s_succ_vector{j} = s_succ;
  m_succ_vector{j} = m_succ;
  s_coll_vector{j} = s_coll;
  m_coll_vector{j} = m_coll;
  j = j + 1;
  i = 1;
end

color = ['r' 'g' 'b'];

figure

%% plot - transmission probability
subplot(2,2,1);
hold on;
grid on;
for iterator = 1:1:j-1
  plot(n_vector, s_tau_vector{iterator}, strcat('p', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, m_tau_vector{iterator}, strcat('--', color(iterator), ';model CW=', num2str(cw_vector(iterator)), ';'));
end
legend("fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Transmission Prob - m = ",num2str(m)));
hold off


%% plot - idle channel probability
subplot(2,2,2);
hold on;
grid on;
for iterator = 1:1:j-1
  plot(n_vector, s_idle_vector{iterator}, strcat('o', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, m_idle_vector{iterator}, strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Idle Channel Prob - m = ",num2str(m)));
hold off

%% plot - sucessful transmission probability
subplot(2,2,3);
hold on;
grid on;
for iterator = 1:1:j-1
  plot(n_vector, s_succ_vector{iterator}, strcat('s', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, m_succ_vector{iterator}, strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("location",'southeast', "fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Successful TX Prob -  m = ",num2str(m)));
hold off


%% plot - collision probability
subplot(2,2,4);
hold on;
grid on;
for iterator = 1:1:j-1
  plot(n_vector, s_coll_vector{iterator}, strcat('^', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, m_coll_vector{iterator}, strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("location",'southeast', "fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Collision Prob - m = ",num2str(m)));
hold off


clear all;
end
