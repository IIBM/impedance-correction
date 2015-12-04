#!/bin/bash

# Genera las imágenes exportadas como tikz en archivos PDF y las
# guarda en el directorio Graficos. Utiliza 'plantilla.tex' como
# envoltura de las figuras tikz, ahí se define todo lo requerido
# según los textos utilizados en octave para leyendas, ejes, etc.

TEMPLATE="plantilla-tikz.tex"
LATEXOUT="texput.pdf"

for tikzfile in *.tikz; do
    if [ -f "$tikzfile" ]; then
        # -------------- workarround para corregir un bug de FLTK --------------
        sed "s/\(\\\\pgftransformrotate.*\)/\1}/g" "$tikzfile" > "$tikzfile.tmp"
        rm "$tikzfile"
        mv "$tikzfile.tmp" "$tikzfile"
        # ----------------------------------------------------------------------
        sed "s/_TIKZ_IMAGE_/$tikzfile/g" $TEMPLATE | pdflatex
        if [ -f "$LATEXOUT" ]; then
            pdfcrop "$LATEXOUT" "$LATEXOUT"
            mv "$LATEXOUT" "${tikzfile%.tikz}.pdf"
        else
            exit 1
        fi
        rm -f texput* "$tikzfile"
    fi
done
