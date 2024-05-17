function setup(htmlComponent) {
    htmlComponent.addEventListener("delProgressDialog", function() {
        try {
            window.parent.parent.document.getElementsByClassName("mw-busyIndicator")[0].remove();
        } catch (ME) {
            // console.log(ME)
        }
    });

    htmlComponent.addEventListener("addKeyDownListener", function(event) {
        let objDataName  = event.Data.DataName.toString();
        let objDataTag   = event.Data.DataTag.toString();
        let objHandle    = window.parent.document.querySelector(`div[data-tag="${objDataTag}"]`).children[0];

        objHandle.addEventListener('keydown', function(event) {
            keyDownListener(event, htmlComponent, objDataName, objHandle);
        });
    });

    htmlComponent.addEventListener("EditFieldFocus", function(event) {
        let objDataName  = event.Data.DataName.toString();
        let objDataTag   = event.Data.DataTag.toString();
        let objHandle    = window.parent.document.querySelector(`div[data-tag="${objDataTag}"]`).querySelector('input');

        try {
            objHandle.focus();
            objHandle.setSelectionRange(objHandle.value.length, objHandle.value.length);
        } catch (ME) {
            // console.log(ME)
        }
    });

    htmlComponent.addEventListener("htmlClassCustomization", function(event) {
        try {
            var className       = event.Data.className.toString();
            var classAttributes = event.Data.classAttributes.toString();
    
            var s = document.createElement('style');
            s.type = 'text/css';
            s.appendChild(document.createTextNode(className + " { " + classAttributes + " }"));    
            window.parent.document.head.appendChild(s);
        } catch (ME) {
            // console.log(ME)
        }
    });
        
    htmlComponent.addEventListener("compCustomization", function(event) {
        let objClass    = event.Data.Class.toString();
        let objDataTag  = event.Data.DataTag.toString();
        let objProperty = event.Data.Property.toString();
        let objValue    = event.Data.Value.toString();
        let objHandle   = window.parent.document.querySelector(`div[data-tag="${objDataTag}"]`);
        
        if (!objHandle) {
            return;
        }
        
        try {
            let elements = null;

            switch (objClass) {
                case "matlab.ui.container.ButtonGroup":
                case "matlab.ui.container.CheckBoxTree":
                case "matlab.ui.container.Panel":
                case "matlab.ui.container.Tree":
                    objHandle.style[objProperty] = objValue;
                    objHandle.children[0].style[objProperty] = objValue;
                    break;
                    
                case "matlab.ui.container.GridLayout":
                    objHandle.style.backgroundColor = objValue;
                    break;
                    
                case "matlab.ui.container.TabGroup":
                    switch (objProperty) {
                        case "backgroundColor":
                            // Pendente!
                            return;                         
                        case "backgroundHeaderColor":
                            objHandle.style.backgroundColor = "transparent";
                            objHandle.children[1].style.backgroundColor = objValue;
                            break;
                        case "transparentHeader":
                            objHandle.style.border = "none";
                            objHandle.style.backgroundColor = "transparent";
                            
                            objHandle.children[1].style.border = "none";
                            objHandle.children[1].style.backgroundColor = "transparent";                            

                            var childElements = objHandle.children[1].querySelectorAll("*");

                            childElements.forEach(function(child) {
                                child.style.border = "none";
                                child.style.backgroundColor = "transparent";                                
                            });
                            break;
                        case "borderRadius":
                        case "borderWidth":
                        case "borderColor":
                            objHandle.style[objProperty] = objValue;
                            break;
                        case "fontFamily":
                        case "fontStyle":
                        case "fontWeight":
                        case "fontSize":
                        case "color":
                            elements = objHandle.getElementsByClassName("mwTabLabel");                            
                            for (let ii = 0; ii < elements.length; ii++) {
                                elements[ii].style[objProperty] = objValue;
                            }
                    }
                    
                case "matlab.ui.container.Tab":
                    // Pendente!
                    return;
                
                case "matlab.ui.control.Button":
                case "matlab.ui.control.DropDown":
                case "matlab.ui.control.EditField":
                case "matlab.ui.control.ListBox":
                case "matlab.ui.control.NumericEditField":
                case "matlab.ui.control.StateButton":
                    objHandle.children[0].style[objProperty] = objValue;
                    break;
                    
                case "matlab.ui.control.TextArea":
                    switch (objProperty) {
                        case "backgroundColor":
                            objHandle.style.backgroundColor = "transparent";
                            objHandle.children[0].style.backgroundColor = objValue;
                            break;                            
                        case "textAlign":
                            objHandle.getElementsByTagName("textarea")[0].style.textAlign = objValue;
                            break;                            
                        default:
                            objHandle.children[0].style[objProperty] = objValue;
                    }
                    
                case "matlab.ui.control.CheckBox":
                    objHandle.getElementsByClassName("mwCheckBoxRadioIconNode")[0].style[objProperty] = objValue;
                    break;

                case "matlab.ui.control.Table":
                    switch (objProperty) {
                        case "backgroundColor":
                            objHandle.children[0].style.backgroundColor = "transparent";
                            objHandle.children[0].children[0].style.backgroundColor = objValue;
                            break;    
                        case "backgroundHeaderColor":
                            objHandle.children[0].children[0].children[0].style.backgroundColor = objValue;
                            break;    
                        case "borderRadius":
                            objHandle.children[0].style.borderRadius = objValue;
                            objHandle.children[0].children[0].style.borderRadius = objValue;
                            break;    
                        case "borderWidth":
                        case "borderColor":
                            objHandle.children[0].children[0].style[objProperty] = objValue;
                            break;
                        case "textAlign":
                        case "paddingTop":
                            elements = objHandle.getElementsByClassName("mw-table-header-row")[0].children;                      
                            for (let ii = 0; ii < elements.length; ii++) {
                                elements[ii].style[objProperty] = objValue;
                            }
                            break;
                        case "fontFamily":
                        case "fontStyle":
                        case "fontWeight":
                        case "fontSize":
                        case "color":
                            elements = objHandle.getElementsByClassName("mw-default-header-cell");
                            for (let ii = 0; ii < elements.length; ii++) {
                                elements[ii].style[objProperty] = objValue;
                            }
                    }
            }
        } catch (ME) {
            // console.log(ME)
        }
    });
}

function keyDownListener(event, htmlComponent, objDataName, objHandle) {
    keyEvents = ["ArrowUp", "ArrowDown", "Enter", "Escape"];

    switch (objDataName) {
        case "app.EditField":
            break;
        case "app.ListBox":
            let selectedItem = objHandle.getElementsByClassName("mwListItem mwListItemSelected");

            if (selectedItem.length == 1) {
                selectedItem[0].dataset.mwIndex != "1"
            }
            break;
    }

    if (keyEvents.includes(event.key)) {
        htmlComponent.sendEventToMATLAB(event.key, objDataName);
    }
}