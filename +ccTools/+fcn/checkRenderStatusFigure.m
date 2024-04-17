function status = checkRenderStatusFigure(fHandle)

    status   = false;
    refPause = .25; % in seconds
    
    kk = 0;
    while kk < 100
        kk = kk+1;

        refPause = refPause/2;
        pause(refPause)
    
        fController = struct(fHandle).Controller;
        if ~isempty(fController) && isprop(fController, 'IsFigureViewReady') && fController.IsFigureViewReady
            status  = true;
            break
        end
    end
end