var SimpleStorage = artifacts.require("SimpleStorage");
var TutorialToken = artifacts.require("TutorialToken");
var ComplexStorage = artifacts.require("ComplexStorage");
var Casino = artifacts.require("Casino");
var Table = artifacts.require("Table");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(TutorialToken);
  deployer.deploy(ComplexStorage);

  var chipPrice = 1000000000000;
  var investment = chipPrice * 100; // 100 chips
  deployer.deploy(Casino, chipPrice).then(function() {
    return Casino.deployed().then(function(casino) {
      return casino.getChipTokenAddress().then(function(chipTokenAddr) {
        return deployer.deploy(Table, casino.address, chipTokenAddr).then(function() {
          return Table.deployed().then(function(table) {
            return casino.registerTable(table.address).then(function() {
              return casino.invest({ value: investment });
            });
          });
        });
      });
    });
  });

  // deployer.deploy(Casino, 1000000000000).then(function() {
  //   return Casino.deployed().then(function(casino) {
  //     return casino.invest({ value: 9000000000000 });
  //     return deployer.deploy(Table, casino.address).then(function() {
  //       return Table.deployed().then(function(table) {
  //         return casino.registerTable(table.address);
  //       });
  //     });
  //   });
  // });
};
