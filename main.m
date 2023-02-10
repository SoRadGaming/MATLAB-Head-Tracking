%% Resetting MATLAB environment
%%instrreset; 
clear ; close all; clc

%% general setting
N_sample        = 1000; % how many samples to collect
%% create phone listener object: Android
m = mobiledev;
disp(m)

%% Initialise empty figure and empty variables
% figure
% h_plot  = plot(NaN,[NaN NaN NaN]);
t       = NaN*ones(N_sample,1);
acc     = NaN*ones(N_sample,3);



%% Loop to start data collection
for i_time = 1:N_sample
%% Android: IMU+GPS Stream
    [t(i_time,:), acc(i_time,:)]        = getandroiddata(phonelistener);
    
    %% plot here
    plot(acc);
    drawnow
end
%% Closing and deleting connections (keep these in your program!)
fclose(phonelistener);%Closing UDP communication
delete(phonelistener);%Deleting UDP communication