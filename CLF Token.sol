// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CLFToken is ERC20Burnable, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) public isMinter;
    uint256 public constant initialSupply = 5000000 ether;
    uint256 public transferFee;
    address public feeAddress;
    mapping(address => bool) public whitelist;

    modifier onlyMinter(address account) {
        require(isMinter[account], "CLF: not minter");
        _;
    }

    constructor(address _feeAddress, uint256 _fee)
        ERC20("Collective Finance", "CLF")
    {
        _mint(msg.sender, initialSupply);
        setFeeAddress(_feeAddress);
        setTransferFee(_fee);
    }

    function addMinter(address account) public onlyOwner {
        isMinter[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        isMinter[account] = false;
    }

    function setTransferFee(uint256 _fee) public onlyOwner {
        require(_fee <= 15, "CLF: transfer fee should be less than 15%");
        transferFee = _fee;
    }

    function setFeeAddress(address account) public onlyOwner {
        require(
            account != address(0),
            "CLF: fee address can't be zero address"
        );
        feeAddress = account;
    }

    function setWhitelist(address account, bool flag) public onlyOwner {
        whitelist[account] = flag;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 feeAmount = whitelist[from] || whiltelist[to]
            ? 0
            : amount.mul(transferFee).div(100);
        uint256 transferAmount = amount.sub(feeAmount);
        if (feeAmount > 0) super._transfer(from, feeAddress, feeAmount);
        super._transfer(from, to, transferAmount);
    }
}
