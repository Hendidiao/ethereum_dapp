pragma solidity ^0.4.24;

contract Owned
{
    address public owner;
    
    constructor() public
    {
        owner = msg.sender;
    }
    
    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public
    {
        owner = newOwner;
    }
    
}

interface tokenRecipient
{
    function recipientApproval(address from, address to, uint value,bytes extraData) external;
}

contract TokenERC20
{
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, uint value);
    
    constructor(string tokenName, string tokenSymbol,uint initialSupply) public
    {
        name = tokenName;
        symbol = tokenSymbol;
        totalSupply = initialSupply * 10 ** uint(decimals);
        balanceOf[msg.sender] = totalSupply;
    }
    
    function _transfer(address _from, address _to, uint _value) internal
    {
        require(_to != 0x00);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        uint previousBalance = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from,_to,_value);
        assert(previousBalance == balanceOf[_from] + balanceOf[_to]);
    }
    
    function transfer(address _to, uint _value) public returns (bool success)
    {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success)
    {
        require(allowance[_from][msg.sender] >= _value);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from,_to,_value);
        return true;
    }
    
    function approval(address _spender,uint _amount) public returns(bool success)
    {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender,_spender,_amount);
        return true;
    }
    
    function approvalAndCall(address _spender,uint _amount,bytes extraData) public returns(bool success)
    {
        tokenRecipient recipient = tokenRecipient(_spender);
        if(approval(_spender,_amount))
        {
            recipient.recipientApproval(msg.sender,this,_amount,extraData);
            return true;          
        }
    }
    
    function burn(uint _value) public returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from,uint _value) public returns(bool success)
    {
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        emit Burn(_from,_value);
        
        return true;
    }
}

contract MyAdvancedToken is TokenERC20,Owned
{
    uint public sellPrice;
    uint public buyPrices;
    
    mapping(address => uint) public frozenOf;
    
    event FrozenFunds(address target,uint frozen);
    
    constructor(string tokenName,string tokenSymbol,uint initialSupply) TokenERC20(tokenName,tokenSymbol,initialSupply) public {}
    
    function _transfer(address _from, address _to, uint _value) internal
    {
        require(_to != 0x00);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        //require(!frozenOf[_from]);
        //require(!frozenAccount[_to]);
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from,_to,_value);
    }
    
    function mintToken(address target,uint mintedAmount) public returns (bool success)
    {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        
        emit Transfer(0,this,mintedAmount);
        emit Transfer(this,target,mintedAmount);
        return true;
    }
    
    function freezeAccount(address target, uint freeze) onlyOwner public returns (bool success)
    {
        require(freeze <= balanceOf[target]);
        frozenOf[target] += freeze ;
        balanceOf[target] -= freeze;
        emit FrozenFunds(target,freeze);
        return true;
    }
    
    function unLockAccounts(address target,uint amount) onlyOwner public returns (bool success)
    {
        require(frozenOf[target] >= amount);
        frozenOf[target] -= amount;
        balanceOf[target] += amount;
        return true;
    }
    
    function setPrices(uint newSellPrices,uint newBuyPrices) onlyOwner public returns (bool success)
    {
        sellPrice = newSellPrices;
        buyPrices = newBuyPrices;
        return true;
    }
    
    function buy() payable public returns (bool success)
    {
        uint amount = msg.value / buyPrices;
        _transfer(this,msg.sender,amount);
        return true;
    }
    
    function sell(uint amount) public returns (bool success)
    {
        address myAddress = this;
        require(myAddress.balance >= amount * sellPrice);
        
        _transfer(msg.sender,this,amount*sellPrice);
        msg.sender.transfer(amount*sellPrice);
        return true;
    }
}