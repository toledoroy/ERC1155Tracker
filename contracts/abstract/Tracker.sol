//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/ISoul.sol";
import "../interfaces/IERC1155Tracker.sol";

/**
 * @title Tracker Contract Functions
 * @dev To Extend Contracts with Token Tracking Funtionality
 */
abstract contract Tracker {
    
    // Target Contract (External Source)
    address internal _targetContract;

    /* Expected to be present in the child contract 
    /// Expose Target Contract
    function getTargetContract() public view virtual override returns (address) {
        return _targetContract;
    }

    /// Get a Token ID Based on account address (Throws)
    function getExtTokenId(address account) public view override returns (uint256) {
        //Validate Input
        require(account != _targetContract, "Tracker: source contract address is not a valid account");
        //Get
        uint256 ownerToken = _getExtTokenId(account);
        //Validate Output
        require(ownerToken != 0, "Tracker: requested account not found on source contract");
        //Return
        return ownerToken;
    }
    */

    /// Set Target Contract
    /// @dev Call this on constructor/initializer
    function _setTargetContract(address targetContract) internal {
        //Validate Interfaces
        // require(IERC165(targetContract).supportsInterface(type(IERC721).interfaceId), "Target Expected to Support IERC721"); //Additional 0.238Kb
        require(IERC165(targetContract).supportsInterface(type(ISoul).interfaceId)
            // || IERC165(targetContract).supportsInterface(type(IERC721).interfaceId)  //That actually won't work
            , "Target contract expected to support ISoul");
        _targetContract = targetContract;
    }

    /// Get a Token ID Based on account address. Mint if needed.
    function _getExtTokenId(address account) internal view returns (uint256) {
        require(account != _targetContract, "Tracker: source contract address is not a valid account");
        uint256 tokenId = ISoul(_targetContract).tokenByAddress(account);
        return tokenId;
    }
    
    /// Get a Token ID Based on account address. Mint if needed.
    function _getExtTokenIdOrMake(address account) internal returns (uint256) {
        uint256 tokenId = _getExtTokenId(account);
        if(tokenId == 0){
            tokenId = ISoul(_targetContract).mintFor(account, "");
        }
        return tokenId;
    }

    /// Get Owner Account By Owner Token
    function _getAccount(uint256 extTokenId) internal view returns (address) {
        return IERC721(_targetContract).ownerOf(extTokenId);
    }

}
