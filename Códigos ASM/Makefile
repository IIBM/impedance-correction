#|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#
#|/////////////////////////////| Configuraciones |\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#
#|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#

# Nombre del fuente del programa
NAME = main

# Número de micro Atmega (88/168/328):
IC = 32

# Hardware programador (USBTiny)
PROGRAMMER = usbtiny

# Ensamblador:
AS = avra
# Biblioteca de inclusiones del ensamblador:
ASLIBPATH = /usr/share/avra
# Flags para ensamblado:
ASFLAGS = -l $(NAME).lss -m $(NAME).map -I $(ASLIBPATH) -D AVRA

# Software de programación (grabado en placa, load):
AVR = avrdude
# Flags para programación (load):
AVRFLAGS = -c $(PROGRAMMER) -p m$(IC)



#|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#
#|////////////////////////| Objetivos y dependencias |\\\\\\\\\\\\\\\\\\\\\\\\|#
#|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#

#--------------------------- Reglas de construcción ---------------------------#
$(NAME).hex: $(NAME).asm
$(NAME).eep.hex: $(NAME).hex

%.hex: %.asm
	$(AS) $(ASFLAGS) $< -o $@


#|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#
#|////////////////////////////| Utilidades extras |\\\\\\\\\\\\\\\\\\\\\\\\\\\|#
#|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|#

#----------------------- Programar (grabar en el micro) -----------------------#
burn-flash: $(NAME).hex
	$(AVR) $(AVRFLAGS) -U flash:w:$(NAME).hex

burn-eeprom: $(NAME).eep.hex
	$(AVR) $(AVRFLAGS) -U eeprom:w:$(NAME).eep.hex

#----------------------------- Opciones del clock -----------------------------#
# Ext. Crystal/Resonator High Freq.
# Start-up time: 16K CK + 64 ms
# CKSEL=1111; SUT=11
fuse-crystal:
	$(AVR) $(AVRFLAGS) -U lfuse:w:0xFF:m -U hfuse:w:0xD9:m

fuse-internal:
	$(AVR) $(AVRFLAGS) -U lfuse:w:0xE1:m -U hfuse:w:0xD9:m

#----------------------------------- Limpiar ----------------------------------#
clean:
	rm -f *.hex *.cof *.obj *.map *.lss
