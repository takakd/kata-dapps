const DappsToken = artifacts.require("./Dappstoken.sol");

module.exports = function(deployer){
    const initialSupply = 1000;
    deployer.deploy(DappsToken, initialSupply, {
        gas: 2000000
    });
}