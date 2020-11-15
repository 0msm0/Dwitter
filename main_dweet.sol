// pragma solidity >=0.5.0 <0.6;
pragma experimental ABIEncoderV2;

contract SendDweet {

    struct User {
        uint age;
        string email;
        uint index;
        uint my_dweet_count;
        mapping (uint => Dweet) my_dweets;
        Dweet[] my_dweets_array;
    }
    mapping (address => User) public users;


    address[] user_index;
    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event LogNewUser (address indexed _address, uint index, string email, uint age);
    event LogUpdateUser (address indexed _address, uint index, string email, uint age);
    // event NewDweet (address indexed _address, uint )

    function isUser(address _address) public view returns (bool yesIsUser){
        if(user_index.length == 0) return false;
        return (user_index[users[_address].index] == _address);  // true means the _address is already registered
    }


    function addUser (string memory _email, uint _age) public returns (bool success)  {
        address _address = msg.sender;
        // require(_address == msg.sender); // works fine but needs to pass _address in function DweetBody

        require(isUser(_address) == false);  // for readability
        users[_address].age = _age;
        users[_address].email = _email;
        users[_address].index = user_index.push(_address) - 1;
        emit LogNewUser(_address, users[_address].index, _email, _age);
        return true;
    }

    function getUser(address _address) public view returns(string memory email, uint age, uint index) {
        require(isUser(_address) == true);
        return (users[_address].email, users[_address].age, users[_address].index);
    }

    function updateUserAge(address _address, uint _age) public returns (bool success) {
        require (isUser(_address) == true);
        require (_address == msg.sender);
        users[_address].age = _age;
        emit LogUpdateUser(_address, users[_address].index, users[_address].email, _age);
        return true;
    }

    function getUserCount() public view onlyOwner returns (uint)  {
        return user_index.length;
    }

    function getUserByIndex(uint _index) public view onlyOwner returns (address) {
        return user_index[_index];
    }



    struct Dweet {
        string dweet_text;
        // string created_at;
        address dweet_creator;
    }

    uint private total_dweets_counter;
    Dweet[] public all_dweets;
    mapping (address => uint[]) public dweets_by_user;  //TRY THIS PRIVATE AND SEE IF FUNCTION GETS RECORDED IN OPEN ETHEREUM LOGS
    // mapping (uint => Dweet[]) public all_dweets;


    // mapping (address => string) public dweet;
    // mapping (address => DweetBody[]) public dweets;
    // mapping (address => uint) public dweet_count;

    function createDweet(string memory _text) public returns (bool) {
        require (isUser(msg.sender) == true);
        uint dweet_index;
        dweet_index = all_dweets.push(Dweet(_text, msg.sender))-1;

        uint _count = users[msg.sender].my_dweet_count;
        users[msg.sender].my_dweets[_count] = Dweet(_text, msg.sender);
        users[msg.sender].my_dweet_count ++;

        users[msg.sender].my_dweets_array.push(Dweet(_text, msg.sender));

        return true;
    }

    function allDweets() external view returns (Dweet[] memory) {
        return all_dweets;
    }

    // since the function is not called by owner - getUsersCount is onlyOwner
    function dweetsByUser(address _address) public view returns (Dweet[] memory) {
        require (isUser(_address) == true);

        Dweet[] memory _dweets = new Dweet[](users[_address].my_dweet_count);
        // for (uint i=0; i < users[_address].my_dweet_count; i++) {
            // _dweets.push(users[_address].my_dweets[i]);
            // _dweets[i] = users[_address].my_dweets[i];
        // }
        return users[_address].my_dweets_array;
        // return _dweets;
    }

    function totalDweetsByUser (address _address) public view returns (uint) {
        return users[_address].my_dweet_count;
    }

    function dweetByIndex(uint _id) public view returns (string memory _dweet, address _creator) {
        _dweet = all_dweets[_id].dweet_text;
        _creator = all_dweets[_id].dweet_creator;
        return  (_dweet, _creator);
    }




}
