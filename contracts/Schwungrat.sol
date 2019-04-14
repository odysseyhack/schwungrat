pragma solidity ^0.5.2;

contract Schwungrat {
    
    /**
     * The following states (see finite state machine) represent
     * all different phases of a protocol.
     **/
    enum ProtocolState {
        Draft,
        TeamFormation,
        Funding,
        Implementation,
        Production,
        Commonized
    }

    // Funding structure
    struct Funding {
        address issuer;
        uint amount;
        uint repayed;
    }

    // data structure that stores a protocol
    struct Protocol {
        string name;
        string description;
        uint createdAt;
        uint updatedAt;
        address manager;
        ProtocolState state;
        uint totalImplementationCost;
        uint balance;
        uint remainingDebt;
        // Funding[] fundings;
    }
    Protocol[] public protocols;
    event NewProtocolRegistered(uint id);
    event ProtocolStateChanged(uint id, ProtocolState oldState, ProtocolState newState);
    
    /**
     * Constructor function
     */
    constructor() public
    {
        // NOTE: the first protocol MUST be emtpy: if you are trying to access to an element
        // of the protocolIds mapping that does not exist (like protocolIds[0x12345]) you will
        // receive 0, that's why in the first position (with index 0) must be initialized
        addProtocol(address(0x0), "", "", 0);
        addProtocol(address(0x263ad5218f4F3b14219F4daF10D44ac5c53691d7), "Example Protocol", "Some example protocol for testing", 5);
    }
    
    /**
     * Function to create a new protocol proposal.
     *
     * @param _protocolName        The protocol name
     * @param _protocolDescription        The protocol description
     * @param _totalCost     Total Cost to implement the protocol
     */
    function createProtocolProposal(string memory _protocolName, string memory _protocolDescription, uint _totalCost) public
    returns(uint)
    {
        return addProtocol(msg.sender, _protocolName, _protocolDescription, _totalCost);
    }
    
    /**
     * Internal Function to add protocol
     *
     * @param _wAddr         Address wallet of the iniator
     * @param _protocolName   Displaying name of the protocol
     * @param _description   Description of the protocol
     * @param _totalCost     Total Cost to implement the protocol
     */
    function addProtocol(address _wAddr, string memory _protocolName, string memory _description, uint _totalCost) private
    returns(uint)
    {
        // storing the new user details
        protocols.push(Protocol({
            name: _protocolName,
            createdAt: now,
            updatedAt: now,
            manager: _wAddr,
            description: _description,
            state: ProtocolState.Draft,
            totalImplementationCost: _totalCost,
            balance: 0,
            remainingDebt: 0
            // fundings: new Funding[](0)
        }));
        uint newProtocolId = protocols.length;
        // protocols[newProtocolId].fundings.push(Funding(msg.sender, msg.value, 0));

        // emitting the event that a new user has been registered
        emit NewProtocolRegistered(newProtocolId);

        return newProtocolId;
    }
    
     /**
     * Get the protocol information by protocol id.
     *
     * @param _id     The ID of the protocol stored on the blockchain.
     */
    function getProtocolById(uint _id) public view
    returns(
        uint id,
        string memory name,
        string memory description,
        uint created,
        uint updated,
        address manager,
        ProtocolState state,
        uint totalImplementationCost,
        uint balance,
        // uint fundingsCount,
        uint remainingDebt
    ) {
        Protocol memory p = protocols[_id];
        // uint fundCount = p.fundings.length;
        // for (uint i=0; i < fundCount; i++) {
        //     debt += (p.fundings[i].amount - p.fundings[i].repayed);
        // }

        return (
            _id,
            p.name,
            p.description,
            p.createdAt,
            p.updatedAt,
            p.manager,
            p.state,
            p.totalImplementationCost,
            p.balance,
            // fundCount, // we cannot return the struct/array itself yet (https://stackoverflow.com/a/52327532/1633985) :(
            p.remainingDebt
        );
    }
    
    /**
     * Return the number of total protocols in the system.
     */
    function totalProtocols() public view returns (uint)
    {
        // NOTE: the total registered user is length-1 because the user with
        // index 0 is empty check the contructor: addUser(address(0x0), "", "");
        return protocols.length - 1;
    }

    /**
     * Change state of protocol as protocol manager
     * @param _id           The ID of the protocol stored on the blockchain.
     * @param _newState     The desired state that protocol should transits to
     */
    function changeProtocolState(uint _id, ProtocolState _newState) public 
    {
        Protocol storage protocol = protocols[_id];
        protocol = protocols[_id]; //TODO: why set the value twice?
        
        // Only the manager of the protocol can publish it for funding
        require(msg.sender == protocol.manager);
        ProtocolState oldState = protocol.state;
        
        if(_newState == ProtocolState.TeamFormation){
            // Only protocols with draft status can be published
            require(protocol.state == ProtocolState.Draft);
            protocol.state = ProtocolState.TeamFormation;
        }
        
        if(_newState == ProtocolState.Funding){
            // Only protocols with draft status can be published
            require(protocol.state == ProtocolState.TeamFormation);
            protocol.state = ProtocolState.Funding;
        }
        
        if(_newState == ProtocolState.Production){
            // Only protocols with funcing status can be published
            require(protocol.state == ProtocolState.Funding);
            protocol.state = ProtocolState.Production;
        }

        if (protocol.state != oldState) {
            emit ProtocolStateChanged(_id, oldState, protocol.state);
        }
    }

    /**
     * Add a funding. (sender = issuer)
     * @param _protocolId The ID of the protocol stored on the blockchain.
     */
    function fundProtocol(uint _protocolId) public payable
    // returns (uint)
    {
        Protocol storage protocol = protocols[_protocolId];
        protocol.balance += msg.value;
        protocol.remainingDebt += msg.value;

        // Funding memory funding = Funding(msg.sender, msg.value, 0);
        // uint newId = protocol.fundings.length;
        // protocol.fundings[newId] = funding;
        // return newId;
    }

    // /**
    //  * Get a funding.
    //  * @param _protocolId The ID of the protocol
    //  * @param _fundingId  The ID of the funding inside the protocol's scope
    //  */
    // function getProtocolFundingById(uint _protocolId, uint _fundingId) public view
    // returns (
    //     address issuer,
    //     uint amount,
    //     uint repayed
    // ) {
    //     Protocol memory protocol = protocols[_protocolId];
    //     return (
    //         protocol.fundings[_fundingId].issuer,
    //         protocol.fundings[_fundingId].amount,
    //         protocol.fundings[_fundingId].repayed
    //     );
    // }
    
    /**
     * Implemented Protocol pays transaction fee back
     * @param _id           The ID of the protocol stored on the blockchain.
     */
    function payTransactionFee(uint _id) public payable
    {
        Protocol storage protocol = protocols[_id];
        protocol = protocols[_id];
        
        // Protocol needs to be Production or Commonized
        require(protocol.state == ProtocolState.Production || protocol.state == ProtocolState.Commonized);
        
        protocol.balance += msg.value;
        
        if (protocol.balance >= 0 && protocol.state == ProtocolState.Production) {
            protocol.state = ProtocolState.Commonized;
            emit ProtocolStateChanged(_id, ProtocolState.Production, protocol.state);
        }

        //TODO: repay debts?
    }

}
