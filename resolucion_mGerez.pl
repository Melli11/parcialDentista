%usuario(Persona,Ciudad)
usuario(lider,capitalFederal).
usuario(alf,lanus).
usuario(roque,laPlata).
usuario(fede, capitalFederal).
 
%Predicado auxiliar
ciudad(Ciudad):-
    cuponVigente(Ciudad,_).

% los functores cupon son de la forma 
%  cupon(Marca,Producto,PorcentajeDescuento)
cuponVigente(capitalFederal,cupon(elGatoNegro,setDeTe,35)).
cuponVigente(capitalFederal,cupon(lasMedialunasDelAbuelo,panDeQueso,43)).
cuponVigente(capitalFederal,cupon(laMuzzaInspiradora,pizzaYBirraParaDos,80)).
cuponVigente(lanus,cupon(maoriPilates,ochoClasesDePilates,75)).
cuponVigente(lanus,cupon(elTano,parrilladaLibre,65)).
cuponVigente(lanus,cupon(niniaBonita,depilacionDefinitiva,73)).


% El predicado accionDeUsuario registra las acciones que el usuario realiza en el sitio
% que  pueden ser: 
% ● comprar con un cupón, que se representa con un functor:  
% compraCupon(PorcentajeDescuento,Fecha,Marca)
% ● recomendar un cupón, representado como: 
% recomiendaCupon(Marca,Fecha,UsuarioRecomendado)

accionDeUsuario(lider,compraCupon(60,"20/12/2010",laGourmet)).
accionDeUsuario(lider,compraCupon(50,"04/05/2011",elGatoNegro)).
accionDeUsuario(alf,compraCupon(74,"03/02/2011",elMundoDelBuceo)).
accionDeUsuario(fede,compraCupon(35,"05/06/2011",elTano)).
 
accionDeUsuario(fede,recomiendaCupon(elGatoNegro,"04/05/2011",lider)).
accionDeUsuario(lider,recomiendaCupon(cuspide,"13/05/2011",alf)).
accionDeUsuario(alf,recomiendaCupon(cuspide,"13/05/2011",fede)).
accionDeUsuario(fede,recomiendaCupon(cuspide,"13/05/2011",roque)).
accionDeUsuario(lider,recomiendaCupon(cuspide,"24/07/2011",fede)).


%   Predicados

%   usuario(Persona,Ciudad)
%   cuponVigente(Ciudad,cupon(Marca,Producto,PorcentajeDescuento)).
%   accionDeUsuario(Usuario,compraCupon(PorcentajeDescuento,Fecha,Marca)).
%   accionDeUsuario(Usuario,recomiendaCupon(Marca,Fecha,UsuarioRecomendado)).

% Predicados Auxiliares

cupon(cupon(Marca,Producto,PorcentajeDescuento)):-
    cuponVigente(_,cupon(Marca,Producto,PorcentajeDescuento)).

% Punto1

% ciudadGenerosa/1: una ciudad es generosa si todos sus cupones vigentes ofrecen más del 
% 60% de descuento. Este predicado debe ser inversible.

ciudadGenerosa(Ciudad):-
    ciudad(Ciudad),
    forall(cuponVigente(Ciudad,Cupon), cuponconDescuentoMayorA60(Cupon)).

cuponconDescuentoMayorA60(cupon(Marca,Producto,Descuento)):-
    cuponVigente(_,cupon(Marca,Producto,Descuento)),
    Descuento > 60.

:-begin_tests(punto1).
    test(resolucion_mGerez,nondet):-
        ciudadGenerosa(lanus).
end_tests(punto1).


% 2) puntosGanados/2: relaciona a una persona y el total de puntos que ganó usando Grupón.
% ● Por cada recomendación exitosa, el usuario gana 5 puntos.
% ● Por cada cupón que haya comprado, el usuario gana 10 puntos.
% ● Por cada recomendación no exitosa, el usuario gana 1 punto


puntosGanados(Persona,Puntos):-
    usuario(Persona,_),
    findall(Puntos,ganoPuntosPorRecomendacion(Persona,Puntos),ListaDePuntosPorReco), %Cuando recomienda puede sumar 5 o 1, no las dos juntas.
    findall(Puntos,ganoPuntosPorCompra(Persona,Puntos),ListaDePuntosPorCompra),% Por cada compra suma 10
    sumlist(ListaDePuntosPorReco, PuntosPorReco),
    sumlist(ListaDePuntosPorCompra, PuntosPorCompra),
    Puntos is PuntosPorReco + PuntosPorCompra.
    

ganoPuntosPorRecomendacion(Persona,Puntos):-
    usuario(Persona,_),
    accionDeUsuario(Persona,recomiendaCupon(MarcaRecomendada,Fecha,OtraPersona)),
    accionDeUsuario(OtraPersona,compraCupon(_,Fecha,MarcaRecomendada)),
    Persona \= OtraPersona,
    Puntos is 5.

ganoPuntosPorRecomendacion(Persona,Puntos):- %no salio bien la recomendacion
    accionDeUsuario(Persona,recomiendaCupon(MarcaRecomendada,Fecha,OtraPersona)),
    not(accionDeUsuario(OtraPersona,compraCupon(_,Fecha,MarcaRecomendada))),
    Puntos is 1.

ganoPuntosPorCompra(Persona,Puntos):-
    usuario(Persona,_),
    accionDeUsuario(Persona,compraCupon(_,_,_)),
    Puntos is 10.



% accionDeUsuario(fede,compraCupon(35,"05/06/2011",elTano)).
% compraCupon(PorcentajeDescuento,Fecha,Marca) 

% accionDeUsuario(fede,recomiendaCupon(elGatoNegro,"04/05/2011",lider)).
% recomiendaCupon(Marca,Fecha,UsuarioRecomendado)


% 3) promedioDePuntosPorMarca/2: relaciona a una marca y el promedio de puntos que fueron 
% ganados a través de los cupones de esa marca.

% contador para las veces que alguien gano puntos por esa marca
% puntos totales de esa marca en nuestro dominio



% 4) lePuedeInteresarElCupon/2: relaciona a una persona y un cupón vigente si la persona vive 
% en la ciudad donde se publica el cupón y además:
% ● la persona ya compró algún cupón de la misma empresa del cupón vigente o...
% ● a la persona le recomendaron algún cupón de la misma empresa del cupón vigente

% OK Punto 4

lePuedeInteresarElCupon(Persona,Cupon):-
    usuario(Persona,CiudadCupon),
    cuponVigente(CiudadCupon,Cupon),
    cumpleRequisito(Persona,Cupon).

cumpleRequisito(Persona,cupon(Marca,_,_)):-
    accionDeUsuario(Persona,compraCupon(_,_,Marca)),
    cupon(compraCupon(_,_,Marca)).
    
cumpleRequisito(Persona,cupon(Marca,_,_)):-
    accionDeUsuario(Usuario,recomiendaCupon(Marca,_,Persona)),
    accionDeUsuario(Persona,compraCupon(_,_,Marca)),
    Usuario \= Persona.
  
    
% 5) nadieLeDioBola/1: nadie le dio bola a un usuario si para cada recomendación que hizo, 
% ningún otro usuario hizo la compra del cupón para la misma marca y la misma fecha que 
% recomendó.


% OK Punto 5

nadieLeDioBola(Usuario):-
    accionDeUsuario(Usuario,_),
    forall(accionDeUsuario(Usuario,recomiendaCupon(Marca,Fecha,OtroUsuario))
    ,(not(accionDeUsuario(OtroUsuario,compraCupon(_,Fecha,Marca))))).

:-begin_tests(punto5).
test(resolucion_mGerez,nondet):-
    nadieLeDioBola(alf),
    nadieLeDioBola(lider).

end_tests(punto1).