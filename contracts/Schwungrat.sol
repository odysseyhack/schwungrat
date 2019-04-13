pragma solidity ^0.5.2;

contract Schwungrat {
    // data structure that stores a protocol
    struct Protocol {
        string name;
        string description;
        uint createdAt;
        uint updatedAt;
        address manager;
    }

    Protocol[] public protocols;




    /**
     * Constructor function
     */
    constructor() public
    {
        // NOTE: the first user MUST be emtpy: if you are trying to access to an element
        // of the usersIds mapping that does not exist (like usersIds[0x12345]) you will
        // receive 0, that's why in the first position (with index 0) must be initialized
        // addUser(address(0x0), "", "");
        addProtocol(address(0x222222222222), "Fancy Protocol", "Description for fancy Protocol");
    }



    
    /**
     * Function to create a new protocol proposal.
     *
     * @param _protocolName        The protocol name
     * * @param _protocolDescription        The protocol description
     */
    function createProtocolProposal(string memory _protocolName, string memory _protocolDescription) public
    returns(uint)
    {
        return addProtocol(msg.sender, _protocolName, _protocolDescription);
    }
    
    /**
     * TBDTBDTBD
     *
     * @param _wAddr         Address wallet of the iniator
     * @param _protcolName   Displaying name of the protocol
     * @param _description   Description of the protocol
     */
    function addProtocol(address _wAddr, string memory _protcolName, string memory _description) private
    returns(uint)
    {
        uint newProtocolId = protocols.length++;

        // storing the new user details
        protocols[newProtocolId] = Protocol({
            name: _protcolName,
            createdAt: now,
            updatedAt: now,
            manager: _wAddr,
            description: _description
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
        address
    ) {
        Protocol memory i = protocols[_id];

        return (
            _id,
            i.name,
            i.createdAt,
            i.updatedAt,
            i.manager
        );
    }
    
    /**
     * Return the number of total protocols in the system.
     */
    function totalProtocols() public view returns (uint)
    {
        // NOTE: the total registered user is length-1 because the user with
        // index 0 is empty check the contructor: addUser(address(0x0), "", "");
        return protocols.length;
    }
    

}
