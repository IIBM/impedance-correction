from math import pi

# Valores deseados
w0_deseado = 2*pi*1e3 # 1 kHz
Q_deseado  = 1

# Importancia de los valores
w0_prioridad = 3
Q_prioridad  = 1

# Valores comerciales
comercial = (1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2, 9.1)

R_comercial = tuple(i * 1e3 for i in comercial) + \
              tuple(i * 1e4 for i in comercial) + \
              tuple(i * 1e5 for i in comercial)

C_comercial = tuple(i * 1e-9 for i in comercial[0:11]) + \
              tuple(i * 1e-7 for i in comercial[0:11]) + \
              tuple(i * 1e-8 for i in comercial[0:11]) + \
              tuple(i * 1e-6 for i in comercial[0:11])

####################################################################################
diferencia_min = 1e20

for r1 in R_comercial:
    for c1 in C_comercial:
        for ra in R_comercial:
            for rb in R_comercial:
                w0_actual = 1 / (r1*c1)
                
                if rb/ra >= 2:
                    continue

                Q_actual = (r1*c1) / (r1*c1*(2-rb/ra))

                diferencia_cuadrada = w0_prioridad * (w0_deseado - w0_actual)**2 + \
                                      Q_prioridad  * (Q_deseado  - Q_actual )**2

                if diferencia_cuadrada < diferencia_min:
                    diferencia_min = diferencia_cuadrada
                    r1_final = r1     
                    c1_final = c1    
                    ra_final = ra    
                    rb_final = rb    
                    w0_final = w0_actual
                    Q_final  = Q_actual 

print ""
print "R1 = %s"         % str(r1_final)
print "C1 = %s"         % str(c1_final)
print "Ra = %s"         % str(ra_final)
print "Rb = %s\n"       % str(rb_final)
print "f0 final = %s"   % str(w0_final/(2*pi))
print "Q final  = %s\n" % str(Q_final)
