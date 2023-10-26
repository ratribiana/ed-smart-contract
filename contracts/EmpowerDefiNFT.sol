// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EmpowerDefiNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    constructor() ERC721("EmpowerDefi NFT", "DefiNFT") {}

    /// @notice Public base URI of EmpowerDefi's NFTs
    string public baseUri = "https://empowerdefi.com/api/v1/nfts/";

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    /**
     * @notice Function to change the baseURI of the NFT
     * @param  _baseUri New base uri string
     */
    function setBaseURI(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function mint(uint256 tokenId) external onlyOwner {
        require(!_exists(tokenId), "Error: TokenId already minted");
        _mint(msg.sender, tokenId);
    }

    /**
     * @notice Burn an NFT.
     * @dev Can only be executed by the admin/deployer wallet.
     * @param tokenId TokenId of the NFT to be burned.
     */
    function burn(uint256 tokenId) public override onlyOwner {
        _burn(tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
     * @notice Query the tokenURI of an NFT.
     * @param tokenId TokenId of an NFT to be queried.
     * @return  string - API address of the NFT's metadata
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
