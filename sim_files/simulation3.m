function [idle, busy, coll, succ, idle_when_busy] = simulation3(n, m, W0, simulation_time)

%% number of access categories (ACs)
nAC = length(W0);
%% backoff counter vector
bc = -1*ones(n, nAC);
%% backoff values table based on priority value
W_values = zeros(nAC,2);
%% contention window size for each node
w = zeros(n, nAC);

for j = 1:nAC
    %% first column - min size of contention window
    W_values(j, 1) = W0(j);
    %% second column - max size of contention window
    W_values(j, 2) = W0(j)*2^m;
endfor

for j = 1:n
    for k = 1:nAC
        %% current backoff counter of each node
        bc(j,k) = randi([0,W_values(k,1)-1]);   % backoff counter initialization (-1)
        %% current contention window of each node
        %% initialized with cw_min
        w(j,k) = W_values(k,1);
    endfor
endfor


%% channel - indicates the channel events
%% each position of this matrix indicates how many nodes and classes transmit at that time
%% =0 --> idle channel
%% =1 --> successful transmission
%% >1 --> collision
channel = zeros(simulation_time, nAC);

idle = zeros(1,nAC);
succ = zeros(1,nAC);
coll = zeros(1,nAC);
busy = zeros(1,nAC);
idle_when_busy = zeros(1,nAC);



i=1;
%%% simulation running
while (i<simulation_time);

    cb = transpose(bc);
    tx_nodes = transpose(find(cb==0));
    not_tx_nodes = transpose(find(cb>0));
    number_txs = numel(tx_nodes);

    %%% see if a node wants to transmit in mutiple classes
    if (number_txs > 1)
        x2=-1;
        j=0;
        for x = fix((tx_nodes-1)/nAC) + 1
            %% if two classes on the same node want to transmit
            %% the one with highest priority wins
            if (x == x2)
                tx_nodes(j) = [];
                j = j - 1;
            endif
            x2 = x;
            j = j + 1;
        endfor
        %% recalculate the number_txs value
        number_txs = numel(tx_nodes);
    endif

    %%% a collision occurs
    if (number_txs > 1)
        %% these nodes double the contention window
        %%  and restart the backoff counter
        for k = tx_nodes
            [x, y] = cvt_index(k, nAC);
            if (w(x,y) < W_values(y, 2))
                w(x,y) = w(x,y)*2;
            endif
            bc(x,y) = randi([0,w(x,y)-1]);
        endfor

    %%% a successfull transmission occurs
    %%% this node resets the contention window to its minimum value
    %%  and restarts the backoff counter
    elseif (number_txs == 1)                                  % Transmission
        [x, y] = cvt_index(tx_nodes, nAC);
        w(x,y) = W_values(y, 1);
        bc(x,y) =  randi([0,w(x,y)-1]);         % randi(cw(k)+1)-1;
    endif

    %% the nodes that have not accessed the channel
    %% decrement its backoff counter
    for k = not_tx_nodes
        [x, y] = cvt_index(k, nAC);
        bc(x,y)=bc(x,y)-1;
    endfor

    %% register the number of nodes accessing the channel
    %% at the discrete time instant i
    for k = tx_nodes
        [x,y] = cvt_index(k, nAC);
        channel(i,y) = channel(i,y) + 1;
    endfor


    %%% process statistics
    tmp = channel(i,:);
    %%% if there is a collision
    %% increase the counter
    if (sum(tmp) > 1)
       for j = 1:nAC
           coll(j) = coll(j) + 1;
       endfor
    else
        %%% if there is a sucessful transmission
        %% add value to class that transmitted
        if (sum(tmp) == 1)
            succ(find(tmp == 1)) = succ(find(tmp == 1)) + 1;
        endif
        %%% if it did not transmit, increase idle
        for j = 1:nAC
            if (sum(tmp) == 1)
                idle_when_busy(j) = idle_when_busy(j) + n - tmp(j);
            else
                idle(j) = idle(j) + n - tmp(j);
            endif
        endfor
    endif

    i=i+1;
endwhile



%% number of channel attempts
for k = 1:nAC
    idle(k) = idle(k) / simulation_time;
    succ(k) = succ(k) / simulation_time;
    coll(k) = coll(k) / simulation_time;
    idle_when_busy(k) = idle_when_busy(k) / simulation_time;
    busy(k) = 1- idle(k)-idle_when_busy(k);
endfor


endfunction


function [x, y] = cvt_index(index, columns)
    x = fix((index-1)/columns) + 1;
    y = rem(index-1,columns) + 1;
endfunction
