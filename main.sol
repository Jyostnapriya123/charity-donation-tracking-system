// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityDonation {
    struct Charity {
        uint id;
        string name;
        address payable wallet;
        uint totalDonations;
    }

    struct Donation {
        uint id;
        uint charityId;
        address donor;
        uint amount;
        uint timestamp;
    }

    uint public charityCount;
    uint public donationCount;

    mapping(uint => Charity) public charities;
    mapping(uint => Donation) public donations;
    mapping(address => uint) public donorTotalDonations;

    event CharityRegistered(uint id, string name, address wallet);
    event DonationMade(uint id, uint charityId, address donor, uint amount, uint timestamp);
    event FundsWithdrawn(uint charityId, uint amount, uint timestamp);

    function registerCharity(string memory _name, address payable _wallet) public {
        charityCount++;
        charities[charityCount] = Charity(charityCount, _name, _wallet, 0);
        emit CharityRegistered(charityCount, _name, _wallet);
    }

    function donate(uint _charityId) public payable {
        require(_charityId > 0 && _charityId <= charityCount, "Charity does not exist");
        require(msg.value > 0, "Donation amount must be greater than zero");

        donationCount++;
        donations[donationCount] = Donation(donationCount, _charityId, msg.sender, msg.value, block.timestamp);
        donorTotalDonations[msg.sender] += msg.value;
        charities[_charityId].totalDonations += msg.value;

        emit DonationMade(donationCount, _charityId, msg.sender, msg.value, block.timestamp);
    }

    function withdrawFunds(uint _charityId, uint _amount) public {
        Charity storage charity = charities[_charityId];
        require(charity.wallet == msg.sender, "Only the charity wallet can withdraw funds");
        require(_amount <= charity.totalDonations, "Insufficient funds");

        charity.wallet.transfer(_amount);
        charity.totalDonations -= _amount;

        emit FundsWithdrawn(_charityId, _amount, block.timestamp);
    }

    function getCharity(uint _charityId) public view returns (string memory, address, uint) {
        Charity memory charity = charities[_charityId];
        return (charity.name, charity.wallet, charity.totalDonations);
    }

    function getDonation(uint _donationId) public view returns (uint, address, uint, uint) {
        Donation memory donation = donations[_donationId];
        return (donation.charityId, donation.donor, donation.amount, donation.timestamp);
    }

    function getDonorTotalDonations(address _donor) public view returns (uint) {
        return donorTotalDonations[_donor];
    }
}
