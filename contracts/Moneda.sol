// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Moneda is ERC20("Token Moneda", "TM"), Ownable {

    function emitir(uint cantidad, address destino) public onlyOwner {
        _mint(destino, cantidad);
    }

    constructor() {
        _mint(msg.sender, 1);
    }

}