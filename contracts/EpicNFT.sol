// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

contract EpicNFT is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;

    // we're using _tokenIds to keep track of the NFTs unique identifier, and it's just a number!
    // It's automatically initialized to 0 when we declare private _tokenIds. So, when we first call makeAnEpicNFT, newItemId is 0.
    // When we run it again, newItemId will be 1, and so on!
    // _tokenIds is state variable which means if we change it, the value is stored on the contract directly.
    Counters.Counter private _tokenIds;

    string baseSvgFirstPart = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string baseSvgSecondPart = "' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Cruel", "Clever", "Angry", "Narrow", "Gentle", "Friendly", "Super", "Infinity", "Best"];
    string[] secondWords = ["Axe", "Machete", "Dagger", "Grenade", "Riffle", "Gun", "Knife", "Sword", "Rocket"];
    string[] thirdWords = ["Totoro", "Lupin", "Pikachu", "Uzumaki", "Ikari", "Goku", "Kinzaru", "Osiba", "Kenchi"];

    string[] colors = ["red", "green", "blue", "indigo", "navy", "purple", "olive"];

    event NewNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and its symbol.
    constructor() ERC721 ("ThreeWordsNFT", "3WORDS") {
        console.log("This is new 3WORDS NFT CONTRACT!");
    }

    // A function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        //seed the random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        rand = rand % firstWords.length; //Number between 0 and the length of the array
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        //seed the random generator
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length; //Number between 0 and the length of the array
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        //seed the random generator
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length; //Number between 0 and the length of the array
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand =  random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns(uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT.
    function makeEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();
        require(newItemId < 50, "Max 50 NFTs done!");

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory color = pickRandomColor(newItemId);
        string memory nftTitle = string(abi.encodePacked(first, second, third));
        // then concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvgFirstPart, color, baseSvgSecondPart, first, second, third, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', nftTitle,
                        '", "description": "Awesome new NFT collection of color squares.","image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("------ Final TokenURI ------");
        console.log(finalTokenUri);
        console.log("----------------------------");

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs unique identifier along with the data associated w/ that unique identifier.
        // It's literally us setting the actual data that makes the NFT valuable
        _setTokenURI(newItemId, finalTokenUri); //see tokenURI info below

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewNFTMinted(msg.sender, newItemId);
    }
}

/*
The tokenURI is where the actual NFT data lives. And it usually links to a JSON file called the metadata that looks something like this:
{
    "name": "Spongebob Cowboy Pants",
    "description": "A silent hero. A watchful protector.",
    "image": "https://i.imgur.com/v7U019j.png"
}

You can customize this, but, almost every NFT has a name, description, and a link to something
like a video, image, etc. It can even have custom attributes on it! Be careful with the structure
of your metadata, if your structure does not match the OpenSea Requirements(https://docs.opensea.io/docs/metadata-standards)
your NFT will appear broken on the website.
For example, OpenSea is a marketplace for NFTs. And, every NFT on OpenSea follows the ERC721 metadata
standard which makes it easy for people to buy/sell NFTs.

We can copy the Spongebob Cowboy Pants JSON metadata above and paste it into https://jsonkeeper.com/.
This website is just an easy place for people to host JSON data and we'll be using it to keep our
NFT data for now. Once you click "Save" you'll get a link to the JSON file.
(For example, mines is https://jsonkeeper.com/b/RUUS). Be sure to test your link out and be sure it all looks good!

If you decide to use your own image, make sure the URL goes directly to the actual image,
not the website that hosts the image! Direct Imgur links look like this - https://i.imgur.com/123123.png
NOT https://imgur.com/gallery/123123. The easiest way to tell is to check if the URL ends in an
image extension like .png or .jpg. You can right click the imgur image and "copy image address".
This will give you the correct URL.

https://drive.google.com/file/d/1fCo_bNdzGauoRWeaUwAwCORoY1BrQsck/view?usp=sharing
https://jsonkeeper.com/b/XX09


https://i.ibb.co/mBRs4hm/logo.jpg
https://jsonkeeper.com/b/D1SK

contracts:
1) 0x3cEb07308A592647DF4b3B6de26d88c344B82DA2
2) 0x9AF096F091F7E06794E8b8B3c50ecA1C28D5ff08

https://rinkeby.rarible.com/token/0x9AF096F091F7E06794E8b8B3c50ecA1C28D5ff08:0

svg: data:image/svg+xml;base64,---
https://www.utilities-online.info/base64

{
    "name": "EpicLordHamburger",
    "description": "An NFT from the highly acclaimed square collection",
    "image": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAzNTAgMzUwIj4NCiAgICA8c3R5bGU+LmJhc2UgeyBmaWxsOiB3aGl0ZTsgZm9udC1mYW1pbHk6IHNlcmlmOyBmb250LXNpemU6IDE0cHg7IH08L3N0eWxlPg0KICAgIDxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9ImJsYWNrIiAvPg0KICAgIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBjbGFzcz0iYmFzZSIgZG9taW5hbnQtYmFzZWxpbmU9Im1pZGRsZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+RXBpY0xvcmRIYW1idXJnZXI8L3RleHQ+DQo8L3N2Zz4="
}

json: data:application/json;base64,---
https://jsonkeeper.com/
data:application/json;base64,ewogICAgIm5hbWUiOiAiRXBpY0xvcmRIYW1idXJnZXIiLAogICAgImRlc2NyaXB0aW9uIjogIkFuIE5GVCBmcm9tIHRoZSBoaWdobHkgYWNjbGFpbWVkIHNxdWFyZSBjb2xsZWN0aW9uIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0TkNpQWdJQ0E4YzNSNWJHVStMbUpoYzJVZ2V5Qm1hV3hzT2lCM2FHbDBaVHNnWm05dWRDMW1ZVzFwYkhrNklITmxjbWxtT3lCbWIyNTBMWE5wZW1VNklERTBjSGc3SUgwOEwzTjBlV3hsUGcwS0lDQWdJRHh5WldOMElIZHBaSFJvUFNJeE1EQWxJaUJvWldsbmFIUTlJakV3TUNVaUlHWnBiR3c5SW1Kc1lXTnJJaUF2UGcwS0lDQWdJRHgwWlhoMElIZzlJalV3SlNJZ2VUMGlOVEFsSWlCamJHRnpjejBpWW1GelpTSWdaRzl0YVc1aGJuUXRZbUZ6Wld4cGJtVTlJbTFwWkdSc1pTSWdkR1Y0ZEMxaGJtTm9iM0k5SW0xcFpHUnNaU0krUlhCcFkweHZjbVJJWVcxaWRYSm5aWEk4TDNSbGVIUStEUW84TDNOMlp6ND0iCn0=

{
    "name": "amer1can's NFT",
    "description": "My new NFT",
    "image": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAzNTAgMzUwIj4KICA8c3R5bGU+LmJhc2UgeyBmaWxsOiB3aGl0ZTsgZm9udC1mYW1pbHk6IHNlcmlmOyBmb250LXNpemU6IDE0cHg7IH08L3N0eWxlPgogIDxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9ImJsYWNrIiAvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBjbGFzcz0iYmFzZSIgZG9taW5hbnQtYmFzZWxpbmU9Im1pZGRsZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+YW1lcjFjYW5Bd2Vzb21lTkZUPC90ZXh0Pgo8L3N2Zz4="
}
data:application/json;base64,ewogICAgIm5hbWUiOiAiYW1lcjFjYW4ncyBORlQiLAogICAgImRlc2NyaXB0aW9uIjogIk15IG5ldyBORlQiLAogICAgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajRLSUNBOGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQjNhR2wwWlRzZ1ptOXVkQzFtWVcxcGJIazZJSE5sY21sbU95Qm1iMjUwTFhOcGVtVTZJREUwY0hnN0lIMDhMM04wZVd4bFBnb2dJRHh5WldOMElIZHBaSFJvUFNJeE1EQWxJaUJvWldsbmFIUTlJakV3TUNVaUlHWnBiR3c5SW1Kc1lXTnJJaUF2UGdvZ0lEeDBaWGgwSUhnOUlqVXdKU0lnZVQwaU5UQWxJaUJqYkdGemN6MGlZbUZ6WlNJZ1pHOXRhVzVoYm5RdFltRnpaV3hwYm1VOUltMXBaR1JzWlNJZ2RHVjRkQzFoYm1Ob2IzSTlJbTFwWkdSc1pTSStZVzFsY2pGallXNUJkMlZ6YjIxbFRrWlVQQzkwWlhoMFBnbzhMM04yWno0PSIKfQ==

3) 0xb4Fb52FD2152f277b1307F5d06F5a3E9aaEC288A

4) two random contract with 3WORDS: 0xd93ed8A20C4083266b5927Fb230f135f7B53bC48
5) with events: 0x66CeeeF396Db2213e119034227c2e1A5E135A30C
6) color, limit50:  0xeea903D138be8F6a6c040f5232259C3BeA25e9D2


https://rinkeby.rarible.com/

*/


