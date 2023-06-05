function [status, errorMsg] = compCustomization(comp, varargin)

    arguments
        comp {validators.mustBeBuiltInComponent}
    end

    arguments (Repeating)
        varargin
    end

    warning('off', 'MATLAB:structOnObject')
    % warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved')

    status   = true;
    errorMsg = '';

    fHandle  = ancestor(comp, 'figure');
    fWebWin  = struct(struct(struct(fHandle).Controller).PlatformHost).CEF;

    compTag  = struct(struct(struct(comp).Controller)).ViewModel.Id;

    % varargin number validation
    if mod(numel(varargin), 2)
        error('Optional parameters must be in pairs.')
    end


    switch class(comp)
        %-----------------------------------------------------------------%
        case {'matlab.ui.container.ButtonGroup'    ...
              'matlab.ui.container.Panel'          ...
              'matlab.ui.container.CheckBoxTree'   ...
              'matlab.ui.container.Tree'           ...
              'matlab.ui.control.Button'           ...
              'matlab.ui.control.CheckBox'         ...
              'matlab.ui.control.DropDown'         ...
              'matlab.ui.control.EditField'        ...
              'matlab.ui.control.ListBox'          ...
              'matlab.ui.control.NumericEditField' ...
              'matlab.ui.control.StateButton'      ...
              'matlab.ui.control.TextArea'}
            p = inputParser;
            d = struct('backgroundColor', '#f0f0f0', ...
                       'borderRadius',    '0px',     ...
                       'borderWidth',     '1px',     ...
                       'borderColor',     '#7d7d7d');
        
            addParameter(p, 'backgroundColor', d.backgroundColor, @(x) validators.mustBeColor(x, 'hex'))
            addParameter(p, 'borderRadius',    d.borderRadius,    @(x) validators.mustBeCSSProperty(x, 'border-radius'))
            addParameter(p, 'borderWidth',     d.borderWidth,     @(x) validators.mustBeCSSProperty(x, 'border-width'))
            addParameter(p, 'borderColor',     d.borderColor,     @(x) validators.mustBeColor(x, 'hex'))
                    
            parse(p, varargin{:});
            propertyName = setdiff(p.Parameters, p.UsingDefaults);

            jsCommand = '';
            for ii = 1:numel(propertyName)
                switch class(comp)
                    case 'matlab.ui.control.CheckBox'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwCheckBoxRadioIconNode")[0].style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, replace(p.Results.(propertyName{ii}), '%', '%%'));

                    otherwise
                        switch propertyName{ii}
                            case 'backgroundColor'
                                jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.%s = "%s";\n' ...
                                                       'document.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n'], jsCommand, compTag, propertyName{ii}, 'transparent', ...
                                                                                                                                                    compTag, propertyName{ii}, p.Results.(propertyName{ii}));
                            otherwise
                                jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n',   jsCommand, compTag, propertyName{ii}, replace(p.Results.(propertyName{ii}), '%', '%%'));
                        end
                end
            end


        %-----------------------------------------------------------------%
        case 'matlab.ui.container.GridLayout'
            p = inputParser;
            d = struct('backgroundColor', '#f0f0f0');
        
            addParameter(p, 'backgroundColor', d.backgroundColor, @(x) validators.mustBeColor(x, 'hex'))

            parse(p, varargin{:});
            propertyName = setdiff(p.Parameters, p.UsingDefaults);

            jsCommand = '';
            for ii = 1:numel(propertyName)
                jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, p.Results.(propertyName{ii}));
            end


        %-----------------------------------------------------------------%
        case {'matlab.ui.container.TabGroup' ...
              'matlab.ui.container.Tab'}

            % PROPERTIES:
            % (A1) headerBackgroundColor
            % (A2) bodyBackgroundColor
            % (B) borderRadius
            % (C) borderWidth
            % (D) borderColor
            % (E) fontFamily
            % (F) fontSize
            % (G) fontWeight
            % (H) color

            % backgroundColor (HEADER)
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').children[1].style.backgroundColor = '#f0f0f0' % PADRÃO DO MATLAB (FICA BONITO)

            % backgroundColor (BODY)
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').style.backgroundColor = 'transparent'; % TABGROUP
            % document.querySelector('div[data-tag="e81e2523-3f56-4f32-b52b-db4c3318da45"]').style.backgroundColor = 'transparent'; % TAB1 (CONFIGURÁVEL NO R2023A)

            % BORDER CUSTOMIZATION
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').style.borderRadius = '10px'; % TABGROUP
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').style.borderWidth = '1px';   % TABGROUP
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').style.borderColor = 'black'; % TABGROUP

            % Font: o elemento [0] É UM IDENTIFICADOR DO TABGROUP, DEVE SER DESCARTADO. ITERAR A PARTIR DO ELEMENTO [1]...
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').getElementsByClassName("mwTabLabel")[2].style.fontFamily = "Courier";
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').getElementsByClassName("mwTabLabel")[2].style.fontSize   = "11px";
            % document.querySelector('div[data-tag="2a54bc5c-4609-40f5-bfb2-3413ff664849"]').getElementsByClassName("mwTabLabel")[2].style.color      = "red"; (CONFIGURÁVEL NO R2023A)



        %-----------------------------------------------------------------%
        case 'matlab.ui.control.Table'

            % PROPERTIES:
            % (A) bodyBackgroundColor
            % (B) borderRadius
            % (C) borderWidth
            % (D) borderColor
            % (E) fontFamily (HEADER)
            % (F) fontSize
            % (G) fontWeight
            % (H) color

            % % HEADER Background Customization
            % document.querySelector('div[data-tag="009059e0-eff4-4556-995f-43f56c0bea63"]').getElementsByClassName("mw-table-flex-dynamic-item")[0].style.backgroundColor
            % = 'red';

            % % BODY Background Customization
            % document.querySelector('div[data-tag="a5159436-5b01-4cde-8d3d-9ec2d6f386ff"]').children[0].style.backgroundColor = 'transparent';

            % % Border Customization
            % document.querySelector('div[data-tag="a5159436-5b01-4cde-8d3d-9ec2d6f386ff"]').children[0].children[0].style.borderWidth  = '1px';
            % document.querySelector('div[data-tag="a5159436-5b01-4cde-8d3d-9ec2d6f386ff"]').children[0].children[0].style.borderRadius = '10px';
            % document.querySelector('div[data-tag="a5159436-5b01-4cde-8d3d-9ec2d6f386ff"]').children[0].children[0].style.borderColor  = 'blue';
            % 
            % % Font Customization (table header)
            % var elements = document.querySelector('div[data-tag="a5159436-5b01-4cde-8d3d-9ec2d6f386ff"]').getElementsByClassName("mw-default-header-cell");
            % 
            % for (let ii = 0; ii < elements.length; ii++) {
            %   elements[ii].style.fontFamily = "Courier";
            %   elements[ii].style.fontSize   = "16px";
            %   elements[ii].style.fontWeight = "16px"; % NÃO TESTADO
            %   elements[ii].style.color      = "red";  % NÃO TESTADO
            % }
            % elements = undefined;


        %-----------------------------------------------------------------%
        case 'matlab.ui.control.Slider'

            % PROPERTIES:
            % (A) backgroundColor
            % (B) rotate
            % (C) height

            % document.querySelector('div[data-tag="ba1f4133-b633-4069-85e0-7f5e86ff4f04"]').getElementsByClassName("mwSliderThumb")[0].style.rotate = '180deg';
            % document.querySelector('div[data-tag="ba1f4133-b633-4069-85e0-7f5e86ff4f04"]').getElementsByClassName("mwSliderThumb")[0].style.height = '9px';
            % document.querySelector('div[data-tag="ba1f4133-b633-4069-85e0-7f5e86ff4f04"]').getElementsByClassName("mwSliderTrack")[0].style.backgroundColor = '#f0f0f0';
    end


    % JS
    try
        fWebWin.executeJS(jsCommand);
        
    catch ME
        status   = false;
        errorMsg = getReport(ME);
    end
end