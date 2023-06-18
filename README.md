# ccTools

Over the past three years, the Custom Components Tools, or simply ccTools, emerged as a way to overcome some limitations of the MATLAB built-in components. 
For example, it is still not possible to edit the font of the header of the uitable, and the modal windows - uialert and uiprogressdlg - have minimal 
customization options, limited to the icon.

I have managed to organize the bits and pieces of code I have developed here and there. As a result, I am now releasing ccTools with the following features:
* A filterable table class.
* A push button class.
* Functions that create modal windows - MessageBox and ProgressDialog.
* Functions that allow customization of certain aspects of the MATLAB built-in components.

The use of ccTools requires adding its root folder to the MATLAB path. 

Metadata files have been generated for the two new classes - the filterable table and the push button - enabling drag and drop of components, as well as the 
configuration of their public properties, directly in App Designer.

The ccTools was developed on the Windows platform and tested on three MATLAB releases - R2021b, R2022b, and R2023a. It is likely to work on R2022a as well, 
but there are no guarantees that all features will be operational in older versions.

Complete documentation available [here](https://github.com/EricMagalhaesDelgado/ccTools/blob/main/html/ccTools.pdf).
