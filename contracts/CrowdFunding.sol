// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./Project.sol";

contract CrowdFunding {

    Project[] private projects;

    //Events

    //event that will be emitted when project starts
    event projectStarted(
        uint _amountToRaise,
        uint _timeLimit,
        string _title,
        string _description,
        address _smartContract,
        address _owner
    );

    //Functions

    //Start Project
    function startProject(
        uint _amountToRaise,
        string calldata _projectTitle,
        string calldata _projectDescription,
        uint _timeLimit,
        address payable _owner,
        uint _minContribution
    ) external {
        require (_minContribution >= 10**16,"Minimum donation amount is 0.01 ETH!");
        Project newProject = new Project(
            _amountToRaise,
            _minContribution,
            _timeLimit,
            _projectTitle,
            _projectDescription,
            _owner
        );
        projects.push(newProject);
        emit projectStarted(
            _amountToRaise,
            _timeLimit,
            _projectTitle,
            _projectDescription,
            address(newProject),
            msg.sender
        );
    }
}