// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Claimable.sol";
import "./libraries/SafeMath.sol";
import "hardhat/console.sol";

/**
 * @title ERC20
 * @dev Simpler version of ERC20 interface
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface IERC721 {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract MultiSender is Claimable {
    using SafeMath for uint256;

    event Multisended(uint256 total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint256 balance);

    modifier hasFee() {
        console.log("into hasFree func");
        if (currentFee(msg.sender) > 0) {
            require(msg.value >= currentFee(msg.sender));
        }
        _;
    }

    // Fallback: reverts if Ether is sent to this smart contract by mistake
    fallback() external { 
        require(msg.data.length == 0);
        revert();
    }

    function initialize(address _owner) public {
        require(!initialized());
        setOwner(_owner);
        setArrayLimit(200);
        setDiscountStep(0.00005 ether);
        setFee(0.005 ether);
        boolStorage[keccak256(abi.encode("multisender_initialized"))] = true;
    }

    function initialized() public view returns (bool) {
        return boolStorage[keccak256(abi.encode("multisender_initialized"))];
    }
 
    function txCount(address customer) public view returns(uint256) {
        return uintStorage[keccak256(abi.encode("txCount", customer))];
    }

    function arrayLimit() public view returns(uint256) {
        return uintStorage[keccak256(abi.encode("arrayLimit"))];
    }

    function setArrayLimit(uint256 _newLimit) public onlyOwner {
        require(_newLimit != 0);
        uintStorage[keccak256(abi.encode("arrayLimit"))] = _newLimit;
    }

    function discountStep() public view returns(uint256) {
        return uintStorage[keccak256(abi.encode("discountStep"))];
    }

    function setDiscountStep(uint256 _newStep) public onlyOwner {
        require(_newStep != 0);
        uintStorage[keccak256(abi.encode("discountStep"))] = _newStep;
    }

    function fee() public view returns(uint256) {
        return uintStorage[keccak256(abi.encode("fee"))];
    }

    function currentFee(address _customer) public view returns(uint256) {
        console.log("into currentFee func");
        if (fee() > discountRate(msg.sender)) {
            return fee().sub(discountRate(_customer));
        } else {
            return 0;
        }
    }

    function setFee(uint256 _newStep) public onlyOwner {
        require(_newStep != 0);
        uintStorage[keccak256(abi.encode("fee"))] = _newStep;
    }

    function discountRate(address _customer) public view returns(uint256) {
        uint256 count = txCount(_customer);
        return count.mul(discountStep());
    }

    function multisendTokenERC20(IERC20 _token, address payable[] calldata _contributors, uint256[] calldata _balances) public hasFee payable {
        require(_contributors.length == _balances.length, "Receivers and balances are different length");
        if (address(_token) == 0x0000000000000000000000000000000000000000){
            multisendEther(_contributors, _balances);
        } else {
            uint256 total = 0;
            require(_contributors.length <= arrayLimit());
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
                _token.transferFrom(msg.sender, _contributors[i], _balances[i]);
                total += _balances[i];
            }
            setTxCount(msg.sender, txCount(msg.sender).add(1));
            emit Multisended(total, address(_token));
        }
    }

    function multisendTokenERC721(IERC721 _token, address[] calldata _contributors, uint256[] calldata _id) public hasFee payable {
        require(address(_token) != address(0x0));
        require(_contributors.length == _id.length, "Receivers and IDs are different length");
        require(_contributors.length <= arrayLimit());
        uint256 total = 0;
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            _token.safeTransferFrom(msg.sender, _contributors[i], _id[i]);
            total ++;
        }
        setTxCount(msg.sender, txCount(msg.sender).add(1));
        emit Multisended(total, address(_token));
    }

    function multisendEther(address payable[] calldata _contributors, uint256[] calldata _balances) public payable {
        console.log("into multisendEther func");
        uint256 total = msg.value;
        uint256 feeValue = currentFee(msg.sender);
        require(total >= feeValue);
        require(_contributors.length <= arrayLimit());
        total = total.sub(feeValue);
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        setTxCount(msg.sender, txCount(msg.sender).add(1));
        emit Multisended(msg.value, 0x0000000000000000000000000000000000000000);
    }

    function claimTokens(address _token) public onlyOwner {
        if (_token == address(0x0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner(), balance);
        emit ClaimedTokens(_token, owner(), balance);
    }
    
    function setTxCount(address customer, uint256 _txCount) private {
        uintStorage[keccak256(abi.encode("txCount", customer))] = _txCount;
    }

}