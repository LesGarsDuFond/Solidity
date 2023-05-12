// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Context.sol";

contract MYD is Context, IERC20 {
    // Mapping des comptes des joueurs
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Mapping des comptes d'une partie en cours des joueurs
    mapping(address => uint256) private _gameBalances;

    uint256 private _totalSupply;

    // Nom et Symbol du Token (Définit au déploiment grace au constructeur)
    string private _name;
    string private _symbol;

    address private _owner;

    // Appliqué lors du déploiment du contract pour définir le nom et le symbol du Token
    // On le définit "payable" car ce contract sera ammené a manipuler des crypto
    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }

    // Fonction pour connaitre le nom du Token (en view car il ne fait aucune modification sur le contract)
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // Idem a la fonction name() mais pour le Symbol
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // Idem aux fonctions name() et symbol() mais pour le nombre de decimales
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    // Fonction pour connaitre le nombre token présent sur le contract
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // Fonction pour connaitre le nombre de token présent sur le compte d'une personne
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    // Pour effectuer un virement d'une personnes a l'autre
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount);
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    // Fonction pour connaitre le nombre de token présent sur la personne appelant la fonction
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Faire un transfert de son compte vers celui de qqn 
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Fonction pour créer un compte
    function createAccout() public {
        require(_balances[msg.sender] > 0 , "Le compte existe deja !");
        _mint(msg.sender, 10*10**18);
    }


    // Fonction pour lancer une partie
    function playGame(uint256 betAmount) public returns(uint256) {
        betAmount = betAmount*10**18;
        require(_balances[msg.sender] >= betAmount, "Montant trop grand !");
        _balances[msg.sender] -= betAmount;
        _gameBalances[msg.sender] += betAmount + betAmount * 2;
        return _gameBalances[msg.sender];
    }

    // Fonction pour retirer des Tokens du compte de jeux lorsque que de l'argent est perdu 
    function loseGame(uint256 loseAmount) public returns(uint256) {
        loseAmount = loseAmount*10**18;
        _gameBalances[msg.sender] -= loseAmount;
        return _gameBalances[msg.sender];
    }

    function finishGame() public {
        _balances[msg.sender] = _gameBalances[msg.sender];
        _gameBalances[msg.sender] = 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0));
        require(recipient != address(0));

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount);
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0));

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0));

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount);
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
