%% BER simulation in Optical OFDM
% This script carries out the simulation of an Optical OFDM scheme.
clear; close all; clc;

%% VARIABLES
% Modulation depth
M = 4;

% Frame size
frame_size = 100;

% Target SNRs in dB
SNR = 0:2:30;

% Maximum number of bits per SNR
max_bits = 1e7; % Maximum detectable BER: 1e-7

% Minimum bit errors to stop current SNR
error_threshold = 5;

% Batch size. This is used to make an adaptive simulation, and hece reduce
% computation cost. Measured in frames.
batch_size = 100;

%% RESULT CONTAINERS
BER = zeros(size(SNR));

%% TX and RX and Channel
% frame_composer and frame_decomposer functions must be implemented. They
% have currently dummy code.
Tx = Transmitter(@qammod, M, frame_size, @frame_composer);
Rx = Receiver(@qamdemod, M, frame_size, @frame_decomposer);

% Please insert here your channel
channel = 1;

%% SIMULATION WORKFLOW
% This part of the script carries out the simulation taking into account
% the typical Tx-> Channel -> Rx flow.

index = 1;

for snr = SNR
    fprintf('Simulation SNR = %1.2f\n',snr);
    to_clear = 0;
    
    % error counter
    current_errors = 0;
    
    % frame counter
    frame_counter = 0;
    
    % We iterate until there are enough errors to estimate BER
    while ((current_errors < error_threshold) && (frame_counter*frame_size*log2(M) < max_bits))
        % We get a batch of frames
        for I = 1:batch_size
            % We generate a random frame
            real_data = randi([0, M-1], frame_size, 1);
            
            % We store it into Tx
            Tx = Tx.pullData(real_data);
            
            % We transmit it
            signal = Tx.transmit();
            
            % We convolve it with the channel and add noise
            rx_signal = awgn(conv(signal, channel), snr, 'measured');
            
            % We receive data
            estimated_data = Rx.receive(rx_signal);
            
            % We count the errors
            current_errors = current_errors + ...
                symerr(real_data, estimated_data);
        end

        if (rem(frame_counter, 10000) == 0)
            clearLine(to_clear);
            to_clear = display_errors(current_errors);
        end
        
        frame_counter = frame_counter + batch_size;
    end
    
    BER(index) = current_errors/(frame_counter*frame_size*log2(M));
    fprintf('\nResult is %1.2f\n', BER(index));
    index = index + 1;
end

%% VISUALIZATION

semilogy(SNR, BER);