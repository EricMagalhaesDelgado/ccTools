function [img_Format, img_String] = img2base64(imgFileFullPath)
%IM2BASE64

% Author.: Eric Magalhães Delgado
% Date...: May 29, 2023
% Version: 1.00

    arguments
        imgFileFullPath {ccTools.validators.mustBeScalarText}
    end

    imgFileFullPath = ccTools.fcn.FileParts(imgFileFullPath);

    try
        [~,~,img_Format] = fileparts(imgFileFullPath);
        switch lower(img_Format)
            case '.png';            img_Format = 'png';
            case {'.jpg', '.jpeg'}; img_Format = 'jpeg';
            case '.gif';            img_Format = 'gif';
            case '.svg';            img_Format = 'svg+xml';
            otherwise;              error('Image file format must be "JPEG", "PNG", "GIF", or "SVG".')
        end

        fileID = fopen(imgFileFullPath, 'r');
        imArray  = fread(fileID, Inf, 'uint8');
        img_String = base64encode(imArray);
        fclose(fileID);
    catch
        img_Format = 'png';
        img_String = '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';
    end
end


function res = base64encode(str)
% base64encode Perform Base 64 encoding of a string or vector of bytes
%   RES = base64encode(V) encodes a string, character vector, or numeric vector using
%   Base 64 encoding as documented in RFC 4648, <a href="http://tools.ietf.org/html/rfc4648#section-4">section 4</a> and returns the encoded 
%   characters as a string.  This encoding is used in a number of contexts in
%   Internet messages where data must be transmitted in a limited set of ASCII
%   characters.  It is often used to encode strings which may have special characters
%   that might be misinterpreted as control characters by the transmission protocol,
%   but it is also used to encode arbitrary binary data.
%
%   If the input is a string or character vector, it is first converted to bytes
%   using the user default encoding.  If you want to use a different character
%   encoding, use unicode2native to convert the string to a uint8 vector before
%   passing it into this function.
%
% See also base64decode, unicode2native

% Copyright 2016 The MathWorks, Inc.
    persistent chars
    if isempty(chars)
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    end
    if isstring(str) || ischar(str)
        % if string or char, get scalar string and decode as bytes
        bytes = unicode2native(char(matlab.net.internal.getString(str, mfilename, 'string')));
    else
        % otherwise, must be vector of integers
        validateattributes(str, {'numeric', 'string'}, {'integer','vector'}, mfilename);
        bytes = uint8(str);
    end
    len = length(bytes);
    if isempty(bytes)
        res = char('');
    else
        res(floor(len*4/3)) = '=';
        bx = 1;
        % in this encoding, each set of 3 bytes is chopped up into 4 6-bit groups, and
        % each 6-bit group is used to index into chars to get the encoded characters
        for i = 1 : 3 : len
            if i+1 <= len
                b1 = bitshift(uint32(bytes(i+1)),8);
                if i+2 <= len
                    b2 = uint32(bytes(i+2));
                else
                    b2 = 0;
                end
            else
                b1 = 0;
                b2 = 0;
            end

            word = bitshift(uint32(bytes(i)),16) + b1 + b2;
            res(bx) = chars(bitshift(word, -18) +1 );
            res(bx+1) = chars(bitand(bitshift(word, -12), 63) + 1);
            if i+1 > len
                res(bx+2) = '=';
                res(bx+3) = '=';
            else
                res(bx+2) = chars(bitand(bitshift(word, -6), 63) + 1);
                if i+2 > len
                    res(bx+3) = '=';
                else
                    res(bx+3) = chars(bitand(word, 63) + 1);
                end
            end
            bx = bx + 4;
        end
    end
    if isstring(str)
        % return a string if input was a string; else return char vector
        res = string(res);
    end
end