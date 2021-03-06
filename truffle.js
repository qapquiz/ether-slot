module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },

    sanbox: {
      host: "http://sandbox.digitopolisstudio.com",
      port: 8545,
      network_id: "*"
    },

    digitopolis: {
      host: "192.168.1.104",
      port: 8545,
      network_id: "5777"
    }
  }
};
