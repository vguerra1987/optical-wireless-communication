classdef Receiver
   
    properties
        %buffer used to carry out demodulation (received symbols plus CP, 
        % headers, CRC, whatever...)
        frame_size; 
        mod_depth; % Modulation depth
        demodulator; % Pointer to demodulation function (QAM, QPSK, 32-QAM, etc...)
        frame_decomposer;
    end
    
    
    methods
        
        % Constructor function
        function obj = Receiver(demodulator, mod_depth, ...
                                   frame_size, frame_decomposer)
            % This constructor receives a pointer to the function used for
            % demodulating data. Typically qammod. frame_size
            % are used to calculate the input buffer size, in symbols.  
            % frame_decomposer is a pointer to the function used to 
            % decompose the frame.
            obj.frame_size = frame_size;
            obj.mod_depth = mod_depth;
            obj.demodulator = demodulator;
            obj.frame_decomposer = frame_decomposer;
        end

        % Frame composition and modulation
        function data = receive(obj, signal)
            % First of all, we decompose the received frame. The
            % frame_decomposer function must extract CP, perform channel
            % equalization, etc...
            rx_symbols = obj.frame_decomposer(signal, obj.frame_size);
            
            % Now we demodulate the extracted symbols.
            data = obj.demodulator(rx_symbols, obj.mod_depth);
            
        end
        
    end
    
end