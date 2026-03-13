%%
%%  IEEE 802.11 model - WiFi model
%%
%%  Rodolfo Oliveira - Nova Univ. of Lisbon
%%
%%
function main
%{
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

n_max = 120;

n_vector = [5 10 20 40 80 120];
cw_vector = [4 8 16];
cw_min = 16; %% contention window

%% stages of retransmission

m=8;



%% simulation time
simulation_time = 1000;%10000

%%%
%%% prinf all simulation parameters
%%%
printf("===================================================================\n");
printf(" n=%d \t CW_min=%d \t m=%d \t simulation time =%d\n", n_max, cw_min,m,simulation_time);
printf("===================================================================\n");



i=1;
for n = n_vector
    for cw_min = cw_vector
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
end


figure

%% Definir marcadores e linhas para distinguir as 3 janelas (CW)
sim_markers = {'<', 'o', 's'};
mod_lines = {'-', '--', ':'};
leg_str = {'sim CW=4', 'mod CW=4', 'sim CW=8', 'mod CW=8', 'sim CW=16', 'mod CW=16'};
m_size = 3; % Reduzido drasticamente
l_width = 1.2; % Ligeiramente mais fino
font_s = 8; % Tamanho da letra da legenda

%% plot - transmission probability
subplot(2,2,1);
hold on;
grid on;
for j = 1:length(cw_vector)
    idx = j:length(cw_vector):length(s_tau);
    plot(n_vector, s_tau(idx), strcat(sim_markers{j}, 'g'), 'MarkerSize', m_size);
    plot(n_vector, m_tau(idx), strcat(mod_lines{j}, 'g'), 'LineWidth', l_width);
end
legend(leg_str, 'location', 'southwest', 'FontSize', font_s);
xlabel('Number of nodes');
ylabel(strcat("Transmission Prob - m = ",num2str(m)));
hold off


%% plot - idle channel probability
subplot(2,2,2);
hold on;
grid on;
for j = 1:length(cw_vector)
    idx = j:length(cw_vector):length(s_idle);
    plot(n_vector, s_idle(idx), strcat(sim_markers{j}, 'b'), 'MarkerSize', m_size);
    plot(n_vector, m_idle(idx), strcat(mod_lines{j}, 'b'), 'LineWidth', l_width);
end
legend(leg_str, 'location', 'northeast', 'FontSize', font_s);
xlabel('Number of nodes');
ylabel(strcat("Idle Channel Prob - m = ",num2str(m)));
hold off

%% plot - sucessful transmission probability
subplot(2,2,3);
hold on;
grid on;
for j = 1:length(cw_vector)
    idx = j:length(cw_vector):length(s_succ);
    plot(n_vector, s_succ(idx), strcat(sim_markers{j}, 'r'), 'MarkerSize', m_size);
    plot(n_vector, m_succ(idx), strcat(mod_lines{j}, 'r'), 'LineWidth', l_width);
end
legend(leg_str, 'location', 'northeast', 'FontSize', font_s);
xlabel('Number of nodes');
ylabel(strcat("Successful TX Prob -  m = ",num2str(m)));
hold off


%% plot - collision probability
subplot(2,2,4);
hold on;
grid on;
for j = 1:length(cw_vector)
    idx = j:length(cw_vector):length(s_coll);
    plot(n_vector, s_coll(idx), strcat(sim_markers{j}, 'm'), 'MarkerSize', m_size);
    plot(n_vector, m_coll(idx), strcat(mod_lines{j}, 'm'), 'LineWidth', l_width);
end
legend(leg_str, 'location', 'southeast', 'FontSize', font_s);
xlabel('Number of nodes');
ylabel(strcat("Collision Prob - m = ",num2str(m)));
hold off


clear all;
end
