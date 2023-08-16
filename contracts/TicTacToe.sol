// SPDX-License-Identifier: GPL-3.0

// Version
pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./Achievement.sol";
import "./Moneda.sol";

// Contrato
contract TicTacToe is VRFConsumerBaseV2 {

    //Variables
    struct Partida {
        address jugador1;
        address jugador2;
        address ganador;
        uint[4][4] jugadas; //matriz 4x4 que almacena las jugadas del juego.
        //Cada celda de la matriz contendrá un valor que representa al jugador que hizo la jugada (1 para jugador1 y 2 para jugador2) o 0 si la celda está vacía.
        address ultimoTurno; //La dirección del jugador que hizo el último movimiento en la partida.
    }

    mapping(uint => uint) requestPartidas;
    //Array dinamico - Coleccion de Partidas.
    Partida[] partidas;
    mapping(address => uint) partidasGanadas;
    Achievement achievement;
    Moneda moneda;

    VRFCoordinatorV2Interface coordinador;
    uint64 idSubscripcion;

    // Constructor
    constructor(address contratoAchievement, address contratoMoneda, address coordinator, uint64 idSub)
    VRFConsumerBaseV2(coordinator) {
        achievement = Achievement(contratoAchievement);
        moneda = Moneda(contratoMoneda);
        coordinador = VRFCoordinatorV2Interface(coordinator);
        idSubscripcion = idSub;
    }

    // Funciones
    function crearPartida(address jug1, address jug2) public returns(uint) {
        require(jug1 != jug2); //identificar que el jug1 es diferente al jug2
        uint idPartida = partidas.length; //el idPartida debe coincidir con el tamaño de partidas
        Partida memory partida; //Crea una nueva instancia de la estructura Partida y
        partida.jugador1 = jug1; //la inicializa con los jugadores jug1 y jug2
        partida.jugador2 = jug2;
        partidas.push(partida); //Agrega la nueva partida a la matriz partidas

        uint reqId = coordinador.requestRandomWords(
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            idSubscripcion,
            3,
            100000,
            1
        );

        requestPartidas[reqId] = idPartida;

        return idPartida; //Devuelve el ID de la nueva partida creada
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {

        uint idPartida = requestPartidas[_requestId];
        uint random = _randomWords[0];

        if (random % 2 == 0) partidas[idPartida].ultimoTurno = partidas[idPartida].jugador1;
        else partidas[idPartida].ultimoTurno = partidas[idPartida].jugador2;
    }

    function jugar(uint idPartida, uint horizontal, uint vertical) public {
        /*Esta función se utiliza para que un jugador realice una jugada en una partida existente.
        Toma como argumentos el idPartida de la partida en la que se quiere jugar, así como las coordenadas
        horizontal y vertical donde el jugador desea realizar su movimiento.
        La función realiza las siguientes validaciones antes de permitir que se realice la jugada:*/
        // Validaciones
        Partida memory partida = partidas[idPartida];
        require(msg.sender == partida.jugador1 || msg.sender == partida.jugador2); //chequear que las cuentas son las registradas en la partida
        require(horizontal > 0 && horizontal < 4); //limitar los movimientos en los espacios de la grilla 1,2,3
        require(vertical > 0 && vertical < 4);
        require(msg.sender != partida.ultimoTurno); //el sender que llama la funcion tiene que ser diferente al ultimoTurno
        require(partida.jugadas[horizontal][vertical] == 0); //Verifica que la celda seleccionada esté vacía (valor igual a 0)
        require(! partidaTerminada(partida)); //Verifica si la partida ya ha terminado (ya hay un ganador o no hay más movimientos posibles)
        require(partida.ultimoTurno != address(0));

        // Guardar la jugada 
        guardarMovimiento(idPartida, horizontal, vertical);
        partida = partidas[idPartida];
        /*Si todas las validaciones son exitosas, la función realiza el movimiento actualizando la matriz de jugadas y luego verifica si hay un ganador
        después de cada movimiento. También guarda el último turno del jugador que realizó la jugada*/

        // Chequear si hay un ganador o si la grilla esta llena
        uint ganador = obtenerGanador(partida);
        guardarGanador(ganador, idPartida);
        
        partidas[idPartida].ultimoTurno = msg.sender; //guarda el sender que hizo la ultima jugada
    }

    function guardarGanador(uint ganador, uint idPartida) private {
        if (ganador != 0) {
            if (ganador == 1) partidas[idPartida].ganador = partidas[idPartida].jugador1;
            else partidas[idPartida].ganador = partidas[idPartida].jugador2;
          /*Esta función privada se utiliza para guardar la dirección del ganador en el campo ganador de la partida 
           si hay un ganador. Recibe como argumentos el valor del ganador (1 o 2) y el idPartida.*/

           //entra al mapping de partidasganadas se le pasa por parametro el ganador y se le incrementa esa cantidad en 1
           partidasGanadas[partidas[idPartida].ganador]++;
           //ahora chechear si llego a 5 ganadas para emitir el contrato achievement
            if (partidasGanadas[partidas[idPartida].ganador] == 5) {
                achievement.emitir(partidas[idPartida].ganador);
            }
            
            //chequea si hay casillas disponibles y devuelve true y si hay ganador emite achievement
            bool casillasDisponibles;
            for(uint x=1; x<4; x++) {
                for(uint y=1; y < 4; y++) {
                    if (partidas[idPartida].jugadas[x][y] == 0) casillasDisponibles = true;
                }
            }
            if (casillasDisponibles) achievement.emitir(partidas[idPartida].ganador);

            if (achievement.balanceOf(partidas[idPartida].ganador) > 0) {
                moneda.emitir(2, partidas[idPartida].ganador);
            }
            else {
                moneda.emitir(1, partidas[idPartida].ganador);
            }
        }
              
    }

    function chequearLinea(uint[4][4] memory jugadas, uint x1,uint y1,uint x2,uint y2,uint x3,uint y3) private pure returns(uint) {
        if ((jugadas[x1][y1] == jugadas[x2][y2]) && (jugadas[x2][y2] == jugadas[x3][y3]))
            return jugadas[x1][y1];
        return 0;
    }

    function obtenerGanador(Partida memory partida) private pure returns(uint) {
        // Check diag \
        uint ganador = chequearLinea(partida.jugadas,1,1,2,2,3,3);
        // Check diag /
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 3,1,2,2,1,3);
        // Check cols |
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1,1,1,2,1,3);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 2,1,2,2,2,3);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 3,1,3,2,3,3);
        // Check rows -
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1,1,2,1,3,1);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1,2,2,2,3,2);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1,3,2,3,3,3);

        return ganador;
    }

    function guardarMovimiento(uint idPartida, uint h, uint v) private {
        if (msg.sender == partidas[idPartida].jugador1) partidas[idPartida].jugadas[h][v] = 1;
        else partidas[idPartida].jugadas[h][v] = 2;
    }

    function partidaTerminada(Partida memory partida) private pure returns(bool) {
        if (partida.ganador != address(0)) return true; //chequea que el ganador sea diferente al vacio por defecto que es 0

        for(uint x=1; x<4; x++) {
            for(uint y=1; y < 4; y++) {
                if (partida.jugadas[x][y] == 0) return false;
            }
        }  //el ciclo for recorre las casillas, si estan vacias devuelve false(NO esta terminada la partida)
          //sino devuelve true
        return true;
    }

    // Modificadores

}