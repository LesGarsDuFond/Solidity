// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract HelloWorld {
    string public greet = "Hello world";

    function maFonction(string memory newGreet) public returns(string memory) {
        string memory greetToUpdate = newGreet;
        greet = greetToUpdate;
        return greetToUpdate;
    }

    function maFonctionAvecStorage() public returns(string memory) {
        string storage greetToUpdate = greet;
        greet = "Hi";
        return greetToUpdate;
    }
}
