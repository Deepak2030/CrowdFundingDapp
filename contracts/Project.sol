// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Project {
    
    // State Variables and mapping
    uint public amountToRaise;
    uint public timeLimit;
    uint public minContribution;
    uint public amountRaised;
    uint public completeAt;
    string public projectTitle;
    string public projectDescription;
    address public smartContract; // what is this variable?
    address payable public owner;
    State public state = State.FundRaising;
    mapping(address => uint) public Contributions;

    //Events

    //event that will be emitted when funding will be receive
    event fundingReceived(uint _amount, address _funder, uint _currentBalance);

    //Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only Owner of this contract has access to this!"
        );
        _;
    }

    modifier stateCheck(State _state) {
        require(state == _state, "Invalid State!");
        _;
    }

    //Enums
    enum State {
        FundRaising,
        Expired,
        Successful
    }

    //Constructor
    constructor(
        uint _amountToRaise,
        uint _minContribution,
        uint _timeLimit,
        string memory _projectTitle,
        string memory _projectDescription,
        address payable _owner
    ) {
        amountToRaise = _amountToRaise;
        minContribution = _minContribution;
        timeLimit = _timeLimit;
        projectDescription = _projectDescription;
        owner = _owner;
        projectTitle = _projectTitle;
        amountRaised = 0;
    }

    //Functions

    //check if the project is still fundable
    function checkState() public {
        if (amountRaised >= amountToRaise){
            state = State.Successful;
        } else if (block.timestamp >= timeLimit){
            state = State.Expired;
        }
        completeAt = block.timestamp; ////!!!!! ---- didnt understand this part
    }

    //Donate
    function fundProject(uint amount) external payable stateCheck(State.FundRaising) returns(bool){
        require(amount >= minContribution);
        // (bool sent, bytes memory data) = own.call{value: msg.value}("");  ///// why people are not using call function here?!?
        // require(sent, "Failed to send Ether");
        Contributions[msg.sender] += msg.value;
        uint currentBalance = amountRaised;
        currentBalance = currentBalance + amount;
        emit fundingReceived(msg.value, msg.sender, amountRaised);
        checkState();
        return true;
    }

    //Withdraw Funds
    function withdrawFunds() onlyOwner() stateCheck(State.Successful) private returns(bool) {    
        (bool sent, ) = owner.call{value: amountToRaise}("");
        require(sent, "Failed to transfer amount!");
        amountRaised = 0;
        return true;
    }

    //Get refund
    function getRefund() stateCheck(State.Expired) public returns(bool) {  /// why did i use the return bool?
        require(Contributions[msg.sender] > minContribution, "You need to contribute first!");
        address payable user = payable(msg.sender);
        (bool sent, ) = user.call{value: Contributions[user]}("");
        require(sent, "Failed to transfer amount!");
        Contributions[user] = 0;
        return true;
    }

    //get details
    function getDetails() public view returns (
        uint _amountToRaise,
        uint _amountRaised,
        uint _minContribution,
        uint _timeLimit,
        address _smartContract,
        address _owner,
        string memory _projectDescription,
        string memory _projectTitle,
        State _state)
    {
        _amountToRaise = amountToRaise;
        _amountRaised = amountRaised;
        _minContribution = minContribution;
        _timeLimit = timeLimit;
        _smartContract = smartContract;
        _owner = owner;
        _projectDescription = projectDescription;
        _projectTitle = projectTitle;
        _state = state;
    }
}