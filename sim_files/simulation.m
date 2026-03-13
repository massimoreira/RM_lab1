function [idle, busy, coll, succ, tau] = simulation(n, m, W0, simulation_time)

%% variables 
i=1;
W_max = W0*2^m;

%% current contention window of each node
%% initialized with cw_min
w = W0*logspace(0,0,n);

%% current backoff counter of each node
bc = -1*logspace(0,0,n);     % backoff counter initialization (-1)
%% initializes the backoff counter (bc) for each node
for k = 1:n
    bc(k)=randi([0,w(k)-1]);
end
%% channel - indicates the channel events
%% each position of this vector indicates how many nodes transmit at that time
%% =0 --> idle channel
%% =1 --> successful transmission
%% >1 --> collision
channel = 0*logspace(0,0,simulation_time);






%%% simulation running
while (i<simulation_time);

    tx_nodes = find(bc==0);
    not_tx_nodes = find(bc>0);
    number_txs = numel(find(bc==0));

    %%% a collision occurs
    %%% these nodes double the contention window
    %%  and restart the backoff counter
    if (number_txs > 1)
        for k = tx_nodes
            if (w(k) < W_max)
                w(k) = w(k)*2;
            end
            bc(k) = randi([0,w(k)-1]);
        end
    %%% a successfull transmission occurs
    %%% this node resets the contention window to its minimum value
    %%  and restarts the backoff counter
    elseif (number_txs == 1)                                  % Transmission
        w(tx_nodes) = W0;
        bc(tx_nodes) =  randi([0,w(tx_nodes)-1]);         % randi(cw(k)+1)-1;
    end

    %% the nodes that have not accessed the channel
    %% decrement its backoff counter
    for k = not_tx_nodes
        bc(k)=bc(k)-1;
    end

    %% register the number of nodes accessing the channel
    %% at the discrete time instant i
    channel(i) = number_txs;
    i=i+1;

end

%% number of channel attempts
attempts= length(channel);

idle = length(find(channel ==0)) / attempts;
succ = length(find(channel ==1)) / attempts;
coll = length(find(channel >1))  / attempts;
tau   = sum(channel) / attempts /n;
busy = 1- idle;

end
