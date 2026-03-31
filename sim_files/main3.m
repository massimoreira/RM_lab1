%%
%%  IEEE 802.11 model - WiFi model
%%
%%  Rodolfo Oliveira - Nova Univ. of Lisbon
%%  revised & expanded by Gonçalo Moreira - 73206
%%
function main3

%%% segundo objetivo
n = 10;

cw_vector = [20 16 10 8];
nAC= length(cw_vector);
cw_min = 8;

T_idle = 1;
T_succ = 150;
T_coll = 160;

m = 8;

iterations = 10;
%% simulation time
simulation_time = 20000;%10000

%%%
%%% print all simulation parameters
%%%
printf("===================================================================\n");
printf(" n=%d \t CW_min=%d \t m=%d \t simulation time =%d\n", n, cw_min,m,simulation_time);
printf(" Number of iterations=%d\n", iterations);
printf("===================================================================\n");



fflush(stdout);

%% run simulation
for i = 1:iterations
    printf("Running interation %d\n", i);
    [idle(i,:), busy(i,:), coll(i,:), succ(i,:), idle_when_busy(i,:)] = simulation3(n, m, cw_vector, simulation_time);
endfor

%% validation if channel probability is 100%
%s_coll(1)+s_succ(1)+s_idle(1)

% throughput calculation (S)
for i = 1:length(cw_vector)
    s_succ(i) = sum(succ(:,i))/iterations;
    s_busy(i) = sum(busy(:,i))/iterations;
    s_idle(i) = sum(idle(:,i))/iterations;
    s_coll(i) = sum(coll(:,i))/iterations;
    s_idle_when_busy(i) = sum(idle_when_busy(:,i))/iterations;
    S_sim(i) = s_succ(i)*T_succ / (s_idle(i)*T_idle + s_succ(i)*T_succ + s_coll(i)*T_coll + s_idle_when_busy(i)*T_succ) * n;

    %{
    m_tau(i) = 2/(cw_vector(i)+1);
    m_idle(i) = (1-m_tau(i))^(n);
    m_busy(i) = 1-m_idle(i);
    m_succ(i) = n*m_tau(i) *(1-m_tau(i))^(n-1);
    m_coll(i) = 1 - m_succ(i) - m_idle(i);
    S_model(i) = m_succ(i)*T_succ / (m_idle(i)*T_idle + m_succ(i)*T_succ + m_coll(i)*T_coll);
    %}
endfor

S_sim
%S_model

%clear all;
end
