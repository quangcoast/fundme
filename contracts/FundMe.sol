//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
//import
import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//error
error FundMe_NotOwner();

//Interface, library, contract

contract FundMe{

    //Type declare
    using  PriceConverter for uint256;

    //State variable
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunder;
    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    //Modifier
    modifier onlyOwner(){
        require(msg.sender == i_owner, "sender not owner");
        _;
    }
    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }
    
    /** @notice this function funds this contract
     *  @dev this implement price feed of our library
     */
    function fund() public payable{
        //require(getConversionRate(msg.value) >= minUsd,"not send");
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,"not send");
        s_funders.push(msg.sender);
        s_addressToAmountFunder[msg.sender]= msg.value;
    }

    function withDraw() public onlyOwner{
        
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunder[funder] = 0;
        }
        s_funders = new address[](0);
        // //transfer 2300 gas still errror
        // payable(msg.sender).transfer(address(this).ballance);
        // //send 2300 gas return bool
        // bool sendSuccess = payable(msg.sender).send(address(this).ballance);
        // require(sendSuccess, "sendFail");
        //call fowward all gas or set gas, returns bool
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call Failed");
    }
    function cheaperWithdraw() public payable onlyOwner{
        address[] memory funders = s_funders;
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunder[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) =    i_owner.call{value: address(this).balance}("");
        require(success);
    }
    
    
}