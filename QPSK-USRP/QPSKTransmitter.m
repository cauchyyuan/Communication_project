classdef QPSKTransmitter < matlab.System  
%#codegen
% Generates the QPSK signal to be transmitted
    
%   Copyright 2012-2016 The MathWorks, Inc.
    
    properties (Nontunable)
        UpsamplingFactor =4;%!!!!!!4
        MessageLength = 105;
        DataLength = 348;%%%   174    348
        TransmitterFilterCoefficients = 1;
        ScramblerBase = 2;
        ScramblerPolynomial = [1 1 1 0 1];
        ScramblerInitialConditions = [0 0 0 0];
    end
    
     properties (Access=private)
        pBitGenerator
        pQPSKModulator 
        pTransmitterFilter
    end
    
    methods
        function obj = QPSKTransmitter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj)
            obj.pBitGenerator = QPSKBitsGenerator(...
                'MessageLength', obj.MessageLength, ...
                'BernoulliLength', obj.DataLength-obj.MessageLength, ...
                'ScramblerBase', obj.ScramblerBase, ...
                'ScramblerPolynomial', obj.ScramblerPolynomial, ...
                'ScramblerInitialConditions', obj.ScramblerInitialConditions);
            obj.pQPSKModulator  = comm.QPSKModulator('BitInput',true, ...
                'PhaseOffset', pi/4);  
            obj.pTransmitterFilter = dsp.FIRInterpolator(obj.UpsamplingFactor, ...
                obj.TransmitterFilterCoefficients);
           
        end
        
        function transmittedSignal = stepImpl(obj)
           
            [transmittedData, ~] = obj.pBitGenerator();
             modulatedData =step(obj.pQPSKModulator,transmittedData); % Generates the data to be transmitted           
            transmittedSignal = obj.pTransmitterFilter(modulatedData); % Square root Raised Cosine Transmit Filter
        end
        
        function resetImpl(obj)
            reset(obj.pBitGenerator);
            reset(obj.pQPSKModulator );
            reset(obj.pTransmitterFilter);
        end
        
        function releaseImpl(obj)
            release(obj.pBitGenerator);
            release(obj.pQPSKModulator );
            release(obj.pTransmitterFilter);
        end
        
        function N = getNumInputsImpl(~)
            N = 0;
        end
    end
end

