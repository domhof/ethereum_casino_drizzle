import ComplexStorage from './../build/contracts/ComplexStorage.json'
import SimpleStorage from './../build/contracts/SimpleStorage.json'
import TutorialToken from './../build/contracts/TutorialToken.json'
// import CasinoToken from './../build/contracts/CasinoToken.json'
import Casino from './../build/contracts/Casino.json'
import Table from './../build/contracts/Table.json'

const drizzleOptions = {
  web3: {
    block: false,
    fallback: {
      type: 'ws',
      url: 'ws://127.0.0.1:7545'
    }
  },
  contracts: [
    ComplexStorage,
    SimpleStorage,
    TutorialToken,
    // CasinoToken,
    Casino,
    Table
  ],
  events: {
    SimpleStorage: ['StorageSet']
  },
  polls: {
    accounts: 1500,
    blocks: 1500
  },
  syncAlways: true
}

export default drizzleOptions