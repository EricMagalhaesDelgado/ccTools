function mustBeCSSProperty(x, PropertyName)
%MUSTBECSSPROPERTY
% MUSTBECSSPROPERTY(x) throws an error if an invalid CSS property
% value is passed.
%
% (A) BORDER-RADIUS
%     border-radius: 30px;
%     border-radius: 50%;
% (B) ...

% Author.: Eric Magalhães Delgado
% Date...: May 12, 2023
% Version: 1.00

    arguments
        x
        PropertyName char {mustBeMember(PropertyName, {'border-radius', 'border-width'})} = 'border-radius'
    end

    try
        switch PropertyName
            case 'border-radius'
                if ischar(x) || (isstring(x) && isscalar(x))
                    y = char(regexpi(x, '\d+px|\d+%', 'match'));
                    if contains(y, '%')
                        z = str2double(extractBefore(y, '%'));
                        if (z < 0) || (z > 100)
                            error(errorMessage(PropertyName))
                        end
                    end        
                    if ~strcmpi(x, y)
                        error(errorMessage(PropertyName))
                    end
                else
                    error(errorMessage(PropertyName))
                end

            case 'border-width'
                if ischar(x) || (isstring(x) && isscalar(x))
                    y = char(regexpi(x, '\d+px', 'match'));
                    if ~strcmpi(x, y)
                        error(errorMessage(PropertyName))
                    end
                else
                    error(errorMessage(PropertyName))
                end

            otherwise
                % others properties...
        end

    catch ME
        throwAsCaller(ME)
    end
end


function msg = errorMessage(PropertyName)
    switch PropertyName
        case 'border-radius'; msg = sprintf('Property "%s" is not valid! Input must be textual - char or scalar string - such as: "50px" | "50%%".', PropertyName);
        case 'border-width';  msg = sprintf('Property "%s" is not valid! Input must be textual - char or scalar string - such as: "0px" | "1px".',   PropertyName);
        otherwise
            % others properties...
    end
end