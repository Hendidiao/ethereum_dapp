pragma solidity ^0.4.24;

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }
}


contract Owned {
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Not Be Authorized");
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
}


contract JKToken is Owned {
    
    using SafeMath for uint;
    
    string public name = "taohuayuan";
    string public symbol = "XND";
    uint8 public decimals = 18;
    uint public totalSupply;
    
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public frozenOf;
    mapping(address => mapping(address => uint)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed from, address indexed to, uint value);
    event FrozenFunds(address indexed target,uint frozen);
    event unFreezeFunds(address indexed target, uint amount);
    
    constructor(uint initialSupply) public {
        totalSupply = initialSupply * 10 ** uint(decimals);
        balanceOf[msg.sender] = totalSupply;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0));
        require(_value > 0);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from,_to,_value);
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from,_to,_value);
        return true;
    }
    
    function approval(address _spender,uint _amount) public returns(bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender,_spender,_amount);
        return true;
    }

    function freeze(address target, uint amount ) public onlyOwner returns (bool success) {
        require(amount >0);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        frozenOf[target] = frozenOf[target].add(amount);
        emit FrozenFunds(target,amount);
        return true;
    }
    
    function unFreezeOf(address target, uint amount) public onlyOwner returns (bool success) {
        frozenOf[target] = frozenOf[target].sub(amount);
        balanceOf[target] = balanceOf[target].add(amount);
        emit unFreezeFunds(target,amount);
        return true;
    }
}