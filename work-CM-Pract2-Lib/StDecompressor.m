function xrec=StDecompressor(BITS,HUFFVAL,scodrec)
% Salidas:
% xrec: vector de codigos ASCII reconstruido
% Entradas
% BITS: Vector columna con el nº de palabras codigo de
% cada longitud (de 1 hasta 16)
% HUFFVAL: Vector columna con los mensajes en orden
% creciente de longitud de palabra
% scodrec: Vector columna tipo string con palabras codigo
% correspondientes a los consecutivos mensajes en x


[HUFFSIZE, HUFFCODE] = HCodeTables(BITS, HUFFVAL);
[MINCODE,MAXCODE,VALPTR] = HDecodingTables(BITS, HUFFCODE);
xrec=DecodeString(scodrec,MINCODE,MAXCODE,VALPTR,HUFFVAL);