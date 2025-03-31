// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZoicTrack {
    address public owner;
    
    // Life event structure
    struct LifeEvent {
        string eventType;
        uint256 timestamp;
    }
    
    // Mapping for animal records
    mapping(string => LifeEvent[]) public lifeEvents;
    mapping(string => string) public certificates;
    mapping(string => address) public ownership;
    
    // Events
    event LifeEventRecorded(
        string indexed alphaCode,
        string eventType,
        uint256 timestamp
    );
    
    event CertificateStored(
        string indexed alphaCode,
        string certHash
    );
    
    event OwnershipTransferred(
        string indexed alphaCode,
        address newOwner
    );
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }
    
    function recordEvent(
        string memory alphaCode,
        string memory eventType
    ) external onlyOwner {
        lifeEvents[alphaCode].push(LifeEvent(
            eventType,
            block.timestamp
        ));
        emit LifeEventRecorded(
            alphaCode,
            eventType,
            block.timestamp
        );
    }
    
    function storeCertificate(
        string memory alphaCode,
        string memory certHash
    ) external onlyOwner {
        certificates[alphaCode] = certHash;
        emit CertificateStored(alphaCode, certHash);
    }
    
    function transferOwnership(
        string memory alphaCode,
        address newOwner
    ) external onlyOwner {
        ownership[alphaCode] = newOwner;
        emit OwnershipTransferred(alphaCode, newOwner);
    }
    
    function getLifeEvents(
        string memory alphaCode
    ) external view returns (LifeEvent[] memory) {
        return lifeEvents[alphaCode];
    }
}