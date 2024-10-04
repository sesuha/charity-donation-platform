// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CharityDonationPlatform {
    struct Charity {
        string name;
        uint256 totalDonations;
        uint256 milestone;
        uint256 fundsReleased;
        address payable charityAddress;
    }

    struct Donation {
        uint256 amount;
        address donor;
    }

    mapping(uint256 => Charity) public charities;
    mapping(uint256 => Donation[]) public donations;
    uint256 public charityCount;

    event CharityAdded(uint256 charityId, string name, address indexed charityAddress);
    event DonationMade(uint256 indexed charityId, uint256 amount, address indexed donor);
    event FundsReleased(uint256 indexed charityId, uint256 amount);

    function addCharity(string memory _name, address payable _charityAddress, uint256 _milestone) public {
        charities[charityCount] = Charity({
            name: _name,
            totalDonations: 0,
            milestone: _milestone,
            fundsReleased: 0,
            charityAddress: _charityAddress
        });
        emit CharityAdded(charityCount, _name, _charityAddress);
        charityCount++;
    }

    function donate(uint256 _charityId) public payable {
        require(_charityId < charityCount, "Charity does not exist");
        require(msg.value > 0, "Donation must be greater than zero");

        charities[_charityId].totalDonations += msg.value;
        donations[_charityId].push(Donation({
            amount: msg.value,
            donor: msg.sender
        }));

        emit DonationMade(_charityId, msg.value, msg.sender);
        releaseFunds(_charityId);
    }

    function releaseFunds(uint256 _charityId) internal {
        Charity storage charity = charities[_charityId];
        if (charity.totalDonations >= charity.milestone && charity.fundsReleased < charity.totalDonations) {
            uint256 amountToRelease = charity.totalDonations - charity.fundsReleased;
            charity.charityAddress.transfer(amountToRelease);
            charity.fundsReleased += amountToRelease;
            emit FundsReleased(_charityId, amountToRelease);
        }
    }

    function getCharityInfo(uint256 _charityId) public view returns (string memory, uint256, uint256, address) {
        Charity memory charity = charities[_charityId];
        return (charity.name, charity.totalDonations, charity.milestone, charity.charityAddress);
    }

    function getDonations(uint256 _charityId) public view returns (Donation[] memory) {
        return donations[_charityId];
    }
}
