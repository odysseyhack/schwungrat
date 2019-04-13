pragma solidity ^0.5.2;

contract Schwungrat {
    
    /**
     * The following states (see finite state machine) represent
     * all different phases of a protocol.
     **/
    enum ProtocolStates {
        Draft,
        TeamFormation,
        Funding,
        Implementation,
        Production,
        Commonized
    }

    // data structure that stores a protocol
    struct Protocol {
        string name;
        string description;
        uint createdAt;
        uint updatedAt;
        address manager;
        ProtocolStates state;
        uint totalImplementationCost;
        uint addionalFees;
    }
    Protocol[] public protocols;
    
    /**
     * Constructor function
     */
    constructor() public
    {
        // NOTE: the first protocol MUST be emtpy: if you are trying to access to an element
        // of the protocolIds mapping that does not exist (like protocolIds[0x12345]) you will
        // receive 0, that's why in the first position (with index 0) must be initialized
        addProtocol(address(0x0), "", "", 0);
        addProtocol(address(0x263ad5218f4F3b14219F4daF10D44ac5c53691d7), "Test Protocol for User1", "Description", 5);
    }
    
    /**
     * Function to create a new protocol proposal.
     *
     * @param _protocolName        The protocol name
     * * @param _protocolDescription        The protocol description
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
     * @param _protcolName   Displaying name of the protocol
     * @param _description   Description of the protocol
     * @param _totalCost     Total Cost to implement the protocol
     */
    function addProtocol(address _wAddr, string memory _protcolName, string memory _description, uint _totalCost) private
    returns(uint)
    {
        uint newProtocolId = protocols.length++;
        // storing the new user details
        protocols[newProtocolId] = Protocol({
            name: _protcolName,
            createdAt: now,
            updatedAt: now,
            manager: _wAddr,
            description: _description,
            state: ProtocolStates.Draft,
            totalImplementationCost: _totalCost,
            addionalFees: 0
        });

        // emitting the event that a new user has been registered
        //emit newUserRegistered(newUserId);

        return newProtocolId;
    }
    
     /**
     * Get the protocol information by protocol id.
     *
     * @param _id     The ID of the protocol stored on the blockchain.
     */
    function getProtocolById(uint _id) public view
    returns(
        uint,
        string memory,
        uint,
        uint,
        address,
        ProtocolStates,
        uint,
        uint
    ) {
        Protocol memory i = protocols[_id];

        return (
            _id,
            i.name,
            i.createdAt,
            i.updatedAt,
            i.manager,
            i.state,
            i.totalImplementationCost,
            i.addionalFees
        );
    }
    
    /**
     * Return the number of total protocols in the system.
     */
    function totalProtocols() public view returns (uint)
    {
        // NOTE: the total registered user is length-1 because the user with
        // index 0 is empty check the contructor: addUser(address(0x0), "", "");
        return protocols.length-1;
    }

    /**
     * Change state of protocol as protocol manager
     * @param _id           The ID of the protocol stored on the blockchain.
     * @param _newState     The desired state that protocol should transits to
     */
    function changeProtocolState(uint _id, ProtocolStates _newState) public 
    {
        Protocol storage protocol = protocols[_id];
        protocol = protocols[_id];
        
        // Only the manager of the protocol can publish it for funding
        require(msg.sender == protocol.manager);
        
        if(_newState == ProtocolStates.TeamFormation){
            // Only protocols with draft status can be published
            require(protocol.state == ProtocolStates.Draft);
            protocol.state = ProtocolStates.TeamFormation;
        }
        
        if(_newState == ProtocolStates.Funding){
            // Only protocols with draft status can be published
            require(protocol.state == ProtocolStates.TeamFormation);
            protocol.state = ProtocolStates.Funding;
        }
        
        if(_newState == ProtocolStates.Production){
            // Only protocols with funcing status can be published
            require(protocol.state == ProtocolStates.Funding);
            protocol.state = ProtocolStates.Production;
        }

    }
    
    /**
     * Implemented Protocol pays transaction fee back
     * @param _id           The ID of the protocol stored on the blockchain.
     * @param _fee          The transaction fee
     */
    function payTransactionFee(uint _id, uint _fee) public 
    {
        Protocol storage protocol = protocols[_id];
        protocol = protocols[_id];
        
        // Protocol needs to be Production or Commonized
        require(protocol.state == ProtocolStates.Production || protocol.state == ProtocolStates.Commonized);
        
        uint newCost = protocol.totalImplementationCost - _fee;
        
        if(newCost > 0){
            protocol.totalImplementationCost = newCost;
        }
        
        if(newCost <= 0 && protocol.state == ProtocolStates.Production){
            protocol.totalImplementationCost = 0;
            protocol.state = ProtocolStates.Commonized;
        }
        
        if(protocol.state == ProtocolStates.Commonized){
            protocol.totalImplementationCost = 0;
            protocol.addionalFees = protocol.addionalFees + _fee;
        }
        
    }

}
