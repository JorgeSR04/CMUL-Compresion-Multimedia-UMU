function [CodedY,CodedCb,CodedCr, Bits, huffval]=EncodeCustomScans(XScan)

% Separa las matrices bidimensionales 
%  para procesar separadamente
YScan=XScan(:,:,1);
CbScan=XScan(:,:,2);
CrScan=XScan(:,:,3);

% Recolectar valores a codificar
[Y_DC_CP, Y_AC_ZCP]=CollectScan(YScan);
[Cb_DC_CP, Cb_AC_ZCP]=CollectScan(CbScan);
[Cr_DC_CP, Cr_AC_ZCP]=CollectScan(CrScan);

DC_C = [Cb_DC_CP;Cb_AC_ZCP];
AC_C = [Cr_DC_CP;Cr_AC_ZCP];

% COntruir las tablas huffman personalizadas
[ehuf_Y, Bits_Y, huffval_Y] = GenerateHUFFTables(Y_DC_CP, Y_AC_ZCP);
[ehuf_C, Bits_C, huffval_C] = GenerateHUFFTables(DC_C, AC_C);

Bits.Y = Bits_Y;
Bits.C = Bits_C;

huffval.Y = huffval_Y;
huffval.C = huffval_C;

ehuf_Y_DC = ehuf_Y.DC;
ehuf_Y_AC = ehuf_Y.AC;
ehuf_C_DC = ehuf_C.DC;
ehuf_C_AC = ehuf_C.AC;

% Codifica en binario cada Scan
% Las tablas de crominancia, ehuf_C_DC y ehuf_C_AC, se aplican, tanto a Cb, como a Cr
CodedY=EncodeSingleScan(YScan, Y_DC_CP, Y_AC_ZCP, ehuf_Y_DC, ehuf_Y_AC);
CodedCb=EncodeSingleScan(CbScan, Cb_DC_CP, Cb_AC_ZCP, ehuf_C_DC, ehuf_C_AC);
CodedCr=EncodeSingleScan(CrScan, Cr_DC_CP, Cr_AC_ZCP, ehuf_C_DC, ehuf_C_AC);
