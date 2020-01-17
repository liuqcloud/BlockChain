'use strict';

let interfaces = [];
interfaces = interfaces.concat(require('./account').interfaces);
interfaces = interfaces.concat(require('./web3j').interfaces);
interfaces = interfaces.concat(require('./crud').interfaces);
interfaces = interfaces.concat(require('./permission').interfaces);
interfaces = interfaces.concat(require('./cns').interfaces);
let commands = interfaces.map(value => value.name);

module.exports.interfaces = interfaces;
module.exports.commands = commands;