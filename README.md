# Practica del juego Tic-Tac-Toe en la Blockchain
![solidity](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)
![ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?logo=ethereum&logoColor=fff&style=for-the-badge)
![openzeppelin](https://img.shields.io/badge/OpenZeppelin-4E5EE4?logo=OpenZeppelin&logoColor=fff&style=for-the-badge)
![Chainlink](https://img.shields.io/badge/Chainlink-375BD2?style=for-the-badge&logo=Chainlink&logoColor=white)

[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)

## Se utilizo el entorno de desarrollo de Remix IDE

Este repositorio contiene un conjunto de contratos inteligentes en Solidity que implementan el juego Tic-Tac-Toe en la cadena de bloques Ethereum. Los contratos utilizan varias bibliotecas e interfaces de OpenZeppelin, incluyendo ERC20, ERC721, Ownable, y la interfaz VRFCoordinatorV2 y VRFConsumerBaseV2 de Chainlink.

## Implementación

1. Implementa los siguientes contratos:
   - `TicTacToe.sol`
   - `Achievement.sol`
   - `Moneda.sol`
   - `Marketplace.sol`

2. Implementa el contrato `TicTacToe` y pasa las direcciones de los contratos como argumentos en su constructor.

## Cómo Jugar

1. Inicializa una partida llamando a la función `crearPartida`, la cual retorna el ID de la partida. Este ID es necesario para acciones posteriores. Asegúrate de proporcionar las direcciones de los jugadores como parámetros.

2. Realiza movimientos en el juego usando la función `jugar`. Proporciona el ID de la partida y el movimiento deseado como argumentos. Los cuadros del tablero están asignados en cordenadas X (horizontal) Y (vertical)

     x1y1  |  x2y1  |  x3y1

     x1y2  |  x2y2  |  x3y2
 
     x1y3  |  x2y3  |  x3y3

3. El juego continúa hasta que un jugador gane al formar una línea con sus símbolos (X o 0) o hasta que el tablero se llene completamente sin un ganador.

## Explicación de los Contratos

- `TicTacToe`: El contrato principal que maneja la lógica del juego y las interacciones. Utiliza diversas bibliotecas de OpenZeppelin y la VRF (Función Aleatoria Verificable) de Chainlink para determinar el primer jugador.

- `Moneda`: Un contrato que representa un token ERC20 usado en el juego.

- `Achievement`: Un contrato ERC721 para otorgar logros a los jugadores que ganen cinco partidas.

- `Marketplace`: Un contrato que permite a los jugadores publicar y ofertar por logros.

## Nota

Este repositorio se proporciona como ejemplo con fines educativos. Muestra cómo implementar el juego Tic-Tac-Toe en la cadena de bloques Ethereum utilizando diferentes contratos inteligentes y bibliotecas. Siéntete libre de explorar, aprender y adaptar el código para tus propios proyectos.

Para explicaciones detalladas de los contratos, consulta los comentarios dentro de los archivos de Solidity.

