function mustBeBuiltInComponent(x)
%MUSTBEBUILTINCOMPONENT

% Author.: Eric Magalhães Delgado
% Date...: June 04, 2023
% Version: 1.00

    warning('off', 'MATLAB:structOnObject')

    BuiltInComponentsList = struct(appdesigner.internal.application.getComponentAdapterMap()).serialization.keys';
    mustBeMember(class(x), BuiltInComponentsList)
    
end