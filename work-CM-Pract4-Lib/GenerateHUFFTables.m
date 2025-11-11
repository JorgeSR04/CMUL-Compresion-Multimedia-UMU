function [ehuf, Bits, huffval] = GenerateHUFFTables(DC_data, AC_data)
    % Calcula frecuencias
    DC_freq = Freq256(DC_data);
    AC_freq = Freq256(AC_data);

    % Genera tablas de especificación
    [DC_BITS, DC_HUFFVAL] = HSpecTables(DC_freq);
    [AC_BITS, AC_HUFFVAL] = HSpecTables(AC_freq);

    % Guardamos Bits y Huffval
    Bits.DC = DC_BITS;
    Bits.AC = AC_BITS;
    huffval.DC = DC_HUFFVAL;
    huffval.AC = AC_HUFFVAL;

    % Genera HUFFSIZE y HUFFCODE
    [DC_HUFFSIZE, DC_HUFFCODE] = HCodeTables(DC_BITS, DC_HUFFVAL);
    [AC_HUFFSIZE, AC_HUFFCODE] = HCodeTables(AC_BITS, AC_HUFFVAL);

    % Genera tablas de codificación final
    [DC_EHUFCO, DC_EHUFSI] = HCodingTables(DC_HUFFSIZE, DC_HUFFCODE, DC_HUFFVAL);
    [AC_EHUFCO, AC_EHUFSI] = HCodingTables(AC_HUFFSIZE, AC_HUFFCODE, AC_HUFFVAL);

    % Concatenar resultados
    ehuf.DC = [DC_EHUFCO, DC_EHUFSI];
    ehuf.AC = [AC_EHUFCO, AC_EHUFSI];
end
