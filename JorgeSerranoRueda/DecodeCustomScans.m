function XScanrec=DecodeCustomScans(CodedY,CodedCb,CodedCr,tam,Bits, huffval)

% DecodeCustomScans: Decodifica los tres scans binarios (Y, Cb, Cr) usando tablas Huffman personalizadas.
%
% Entradas:
%   CodedY   : Cadena binaria codificada del componente Y
%   CodedCb  : Cadena binaria codificada del componente Cb
%   CodedCr  : Cadena binaria codificada del componente Cr
%   tam      : Tamaño del scan a reconstruir [mamp namp]
%   Bits     : Estructura con las tablas de longitud de código Huffman (Y y C)
%   huffval  : Estructura con los valores Huffman asociados (Y y C)
%
% Salidas:
%   XScanrec : Matriz tridimensional (mamp × namp × 3) con los scans reconstruidos
%              de luminancia (Y) y crominancia (Cb y Cr)
%
disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion DecodeCustomScans:');
end

% Instante inicial
tc=cputime;

% Construir tablas Huffman para Luminancia y Crominancia

    % ---- Construir tablas Huffman para Luminancia y Crominancia ----
    huffDec_Y = RecoverHUFFTables(Bits.Y, huffval.Y);
    huffDec_C = RecoverHUFFTables(Bits.C, huffval.C);

    % ---- Luminancia ----
    mincode_Y_DC = huffDec_Y.DC.MINCODE;
    maxcode_Y_DC = huffDec_Y.DC.MAXCODE;
    valptr_Y_DC  = huffDec_Y.DC.VALPTR;
    huffval_Y_DC = huffval.Y.DC;

    mincode_Y_AC = huffDec_Y.AC.MINCODE;
    maxcode_Y_AC = huffDec_Y.AC.MAXCODE;
    valptr_Y_AC  = huffDec_Y.AC.VALPTR;
    huffval_Y_AC = huffval.Y.AC;

    % ---- Crominancia ----
    mincode_C_DC = huffDec_C.DC.MINCODE;
    maxcode_C_DC = huffDec_C.DC.MAXCODE;
    valptr_C_DC  = huffDec_C.DC.VALPTR;
    huffval_C_DC = huffval.C.DC;

    mincode_C_AC = huffDec_C.AC.MINCODE;
    maxcode_C_AC = huffDec_C.AC.MAXCODE;
    valptr_C_AC  = huffDec_C.AC.VALPTR;
    huffval_C_AC = huffval.C.AC;

% Decodifica en binario cada Scan
% Las tablas de crominancia se aplican, tanto a Cb, como a Cr
YScanrec=DecodeSingleScan(CodedY,mincode_Y_DC,maxcode_Y_DC,valptr_Y_DC,huffval_Y_DC,mincode_Y_AC,maxcode_Y_AC,valptr_Y_AC,huffval_Y_AC,tam);
CbScanrec=DecodeSingleScan(CodedCb,mincode_C_DC,maxcode_C_DC,valptr_C_DC,huffval_C_DC,mincode_C_AC,maxcode_C_AC,valptr_C_AC,huffval_C_AC,tam);
CrScanrec=DecodeSingleScan(CodedCr,mincode_C_DC,maxcode_C_DC,valptr_C_DC,huffval_C_DC,mincode_C_AC,maxcode_C_AC,valptr_C_AC,huffval_C_AC,tam);
% Reconstruye matriz 3-D
XScanrec=cat(3,YScanrec,CbScanrec,CrScanrec);

% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Scans decodificados');
    disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
    disp('Terminado DecodeScans_dflt');
end