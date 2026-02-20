classdef SymbolExtractor < matlab.System
    methods (Access = protected)
        function out = isInputSizeMutableImpl(obj, ~)
            out = true;
        end
        
        function out = stepImpl(obj, in)
            if isempty(in)
                out = uint8(0);
            else
                out = uint8(in(1));
            end
        end
        
        function out = getOutputSizeImpl(obj)
            out = [1 1];
        end
        
        function out = getOutputDataTypeImpl(obj)
            out = 'uint8';
        end
        
        function out = isOutputFixedSizeImpl(obj)
            out = true;
        end
        
        function out = isOutputComplexImpl(obj)
            out = false;
        end
    end
end