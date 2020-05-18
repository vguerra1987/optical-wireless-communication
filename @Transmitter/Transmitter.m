classdef Transmitter
   
    properties
        inputBuffer; %buffer used to carry out modulation (receives symbols)
        mod_depth; % Modulation depth
        modulator; % Pointer to modulation function (QAM, QPSK, 32-QAM, etc...)
        frame_composer;
    end
    
    
    methods
        
        % Constructor function
        function obj = Transmitter(modulator, mod_depth, ...
                                   frame_size, frame_composer)
            % This constructor receives a pointer to the function used for
            % modulating data. Typically qammod. frame_size
            % are used to calculate the input buffer size, in symbols.  
            % frame_composer is a pointer to the function used to compose
            % the frame.
            obj.inputBuffer = zeros(frame_size, 1);
            obj.mod_depth = mod_depth;
            obj.modulator = modulator;
            obj.frame_composer = frame_composer;
        end
        
        % Function to get data from a buffer
        function obj = pullData(obj, prng)
            % We asume that data is properly ordered inside prng
            obj.inputBuffer = prng(1:length(obj.inputBuffer));
        end
        
        % Frame composition and modulation
        function signal = transmit(obj)
            % First of all we generate the mapped symbols. If bit loading
            % and power allocation are intended, this function should be
            % properly changed.
            mapped = obj.modulator(obj.inputBuffer, obj.mod_depth);
            
            % Now we compose the frame. This function must take into
            % account Hermittian Symmetry.
            signal = obj.frame_composer(mapped);
            
            % Finally, clipping since we are using optical sources.
            % Currently
            %signal(signal < 0) = 0;
        end
        
    end
    
end