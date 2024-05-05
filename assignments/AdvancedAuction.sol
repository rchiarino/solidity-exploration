// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Entrega final Renzo Chiarino para el modulo 2


/*
    FUNCIONES:
    [-] iniciarSubasta(uint256 valorInicial, uint256 fechaInicio, uint256 duracion): Inicia la subasta con las variables de estado especificadas.
    [-] ofertar(bool secreta, uint256 monto): Permite a los participantes ofertar por el artículo. Las ofertas pueden ser ficticias o reales (usando msg.value).
    [ ] finalizarSubasta(): Finaliza la subasta manualmente (por el creador del contrato) o automáticamente al superar la fecha de finalización.
    [ ] mostrarGanador(): Muestra el ofertante ganador y el valor de la oferta.
    [?] mostrarOfertas(): Muestra la lista de ofertantes y los montos ofrecidos.

    EVENTOS:
    [-] NuevaOferta(address ofertante, uint256 oferta, bool secreta): Se emite cuando se realiza una nueva oferta.
    [ ] SubastaFinalizada(address ganador, uint256 oferta): Se emite cuando finaliza la subasta.

    EXTRA:
    [?] Finalización automática: Se puede implementar un modificador que verifique si la fecha actual ha superado la fecha de finalización de la subasta y, en caso afirmativo, finalice la subasta automáticamente.


*/

contract AdvancedAuction {
    address contractOwner;

    constructor() {
        contractOwner = msg.sender; 
    }

    struct Bid {
        address bidder;
        uint256 amount;
    }

    Bid[] bidds; 
    
    uint256 public currentBid; // The current bid amount
    uint256 public startingDate; 
    uint256 public duration;
    uint256 public endDate; 
    address public winner;
    uint256 public winningBid;
    bool public ended;

    event NewBid(address bidder, uint256 amount, bool secret);
    event EndedAuction(address winner, uint256 amount);

    modifier onlyOwnerHasAccess {
        require(msg.sender == contractOwner, "Only the contract owner has access to this function");
        _;
    }

    modifier auctionNotEnded {
        require(!ended, "The auction has already ended");
        _;
    }

    modifier amountIsValid(uint256 _amount) {
        require(_amount > currentBid, "The bid amount must be greater than the current bid");
        _;
    }

    // Check if the starting date is in the future
    modifier validStartingDate(uint256 _startingDate) {
        require(_startingDate > block.timestamp, "Starting date must be in the future");
        _;
    }

    // Check if the duration is greater than 0
    modifier validDuration(uint256 _duration) {
        require(_duration > 0, "Duration must be greater than 0");
        _;
    }

    // Check if the time has passed the end date
    modifier autoEndAuction {
        if (block.timestamp >= endDate) {
            // Terminar la subasta
        } else {
            _;
        }
    }


    function startAuction(uint256 _startingBid, uint256 _startingDate, uint256 _duration) public validStartingDate(_startingDate) validDuration(_duration) {
        currentBid = _startingBid;
        startingDate = _startingDate;
        duration = _duration;
        endDate = startingDate + duration;
    }
    
    function bid(bool _isSecret, uint256 _amount) public payable auctionNotEnded amountIsValid(_amount) autoEndAuction {
        Bid memory newBid = Bid(msg.sender, _amount);
        bidds.push(newBid);
        currentBid = _amount;
        emit NewBid(msg.sender, _amount, _isSecret);
    }

    function getBids() public view returns (Bid[] memory) {
        return bidds;
    }

}