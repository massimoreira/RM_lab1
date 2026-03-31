%%
%%  IEEE 802.11 model - WiFi model
%%
%%  Rodolfo Oliveira - Nova Univ. of Lisbon
%%  revised & expanded by Gonçalo Moreira - 73206
%%
function main2

%%% segundo objetivo
n_max = 120;
n_vector = [5 10 20 40 80 120];

cw_vector = [4 8 16];
cw_min = 4;

T_idle = 1; %1
T_succ = 150; %150
T_coll = 160; %160

m_vector = [0 1 4 8 12];


%% simulation time
simulation_time = 10000;%10000

%%%
%%% print all simulation parameters
%%%
printf("===================================================================\n");
printf(" n=%d \t CW_min=%d \t m=%d \t simulation time =%d\n", n_max, cw_min,m_vector(1),simulation_time);
printf("===================================================================\n");




i=1;
j=1;
k=1;
m_throughput = zeros(length(m_vector), length(cw_vector), length(n_vector));
s_throughput = zeros(length(m_vector), length(cw_vector), length(n_vector));
for cw_min = cw_vector
  for m = m_vector
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
        %m_coll(i)+m_succ(i)+m_idle(i);

        % throughput calculation (S)
        S_model(i) = m_succ(i)*T_succ / (m_idle(i)*T_idle + m_succ(i)*T_succ + m_coll(i)*T_coll);
        S_sim(i) = s_succ(i)*T_succ / (s_idle(i)*T_idle + s_succ(i)*T_succ + s_coll(i)*T_coll);

        i=i+1;
    end
    m_throughput(k, j, :) = S_model;
    s_throughput(k, j, :) = S_sim;
    j = j + 1;
    i = 1;
  end
  k = k + 1;
  j = 1;
end

color = ['r' 'g' 'b' 'm' 'k'];

figure

%{
%% plot for m_vector(1)
graph(1) = subplot(3,2,1);
hold on;
grid on;
for iterator = 1:1:length(cw_vector)
  plot(n_vector, squeeze(s_throughput(1, iterator, :)), strcat('p', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(1, iterator, :)), strcat('--', color(iterator), ';model CW=', num2str(cw_vector(iterator)), ';'));
end
legend("fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - m = ",num2str(m_vector(1))));
hold off


%% plot for m_vector(2)
graph(2) = subplot(3,2,2);
hold on;
grid on;
for iterator = 1:1:length(cw_vector)
  plot(n_vector, squeeze(s_throughput(2, iterator, :)), strcat('o', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(2, iterator, :)), strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - m = ",num2str(m_vector(2))));
hold off

%% plot for m_vector(3)
graph(3) = subplot(3,2,3);
hold on;
grid on;
for iterator = 1:1:length(cw_vector)
  plot(n_vector, squeeze(s_throughput(3, iterator, :)), strcat('s', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(3, iterator, :)), strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value -  m = ",num2str(m_vector(3))));
hold off


%% plot for m_vector(4)
graph(4) = subplot(3,2,4);
hold on;
grid on;
for iterator = 1:1:length(cw_vector)
  plot(n_vector, squeeze(s_throughput(4, iterator, :)), strcat('^', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(4, iterator, :)), strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("location",'southeast', "fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - m = ",num2str(m_vector(4))));
hold off


%% plot for m_vector(5)
graph(5) = subplot(3,2,5);
hold on;
grid on;
for iterator = 1:1:length(cw_vector)
  plot(n_vector, squeeze(s_throughput(5, iterator, :)), strcat('d', color(iterator), ";sim. CW=", num2str(cw_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(5, iterator, :)), strcat('--', color(iterator), ";model CW=", num2str(cw_vector(iterator)), ';'));
end
legend("location",'southeast', "fontsize", 15);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - m = ",num2str(m_vector(5))));
hold off
%}


%% plot for cw_vector(1)
graph(1) = subplot(2,2,1);
hold on;
grid on;
for iterator = 1:1:length(m_vector)
  plot(n_vector, squeeze(s_throughput(1, iterator, :)), strcat('p', color(iterator), ";sim. m=", num2str(m_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(1, iterator, :)), strcat('--', color(iterator), ';model m=', num2str(m_vector(iterator)), ';'));
end
legend("fontsize", 12);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - CW = ",num2str(cw_vector(1))));
hold off


%% plot for cw_vector(2)
graph(2) = subplot(2,2,2);
hold on;
grid on;
for iterator = 1:1:length(m_vector)
  plot(n_vector, squeeze(s_throughput(2, iterator, :)), strcat('p', color(iterator), ";sim. m=", num2str(m_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(2, iterator, :)), strcat('--', color(iterator), ';model m=', num2str(m_vector(iterator)), ';'));
end
legend("fontsize", 12);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - CW = ",num2str(cw_vector(2))));
hold off


%% plot for m_vector(1)
graph(3) = subplot(2,2,3);
hold on;
grid on;
for iterator = 1:1:length(m_vector)
  plot(n_vector, squeeze(s_throughput(3, iterator, :)), strcat('p', color(iterator), ";sim. m=", num2str(m_vector(iterator)), ';'));
  plot(n_vector, squeeze(m_throughput(3, iterator, :)), strcat('--', color(iterator), ';model m=', num2str(m_vector(iterator)), ';'));
end
legend("fontsize", 12);
xlabel('Number of nodes');
ylabel(strcat("Throughput Value - CW = ",num2str(cw_vector(3))));
hold off


%% make all plots linked
%% and share the same Y axis
linkaxes(graph, 'y');
ylim([0 1]);


%clear all;
end
