// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XNftV2 is ERC1155URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;

    string public name = "XNft-collection-V2";
    string public symbol = "XNftV2";

    constructor() ERC1155("") {}

    function mint(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        _nftIds.increment();

        uint256 nftId = _nftIds.current();

        _mint(recipient, nftId, 1, "");
        _setURI(nftId, tokenURI);

        return nftId;
    }

    function mintBatch(
        address recipient,
        uint256[] memory amounts,
        string[] memory tokenURIs
    ) public onlyOwner {
        uint256[] memory nftIds;

        for (uint256 i = 0; i < amounts.length; i++) {
            _nftIds.increment();
            nftIds[i] = _nftIds.current();

            _setURI(nftIds[i], tokenURIs[i]);
        }

        _mintBatch(recipient, nftIds, amounts, "");
    }
}
