import React, { Component } from 'react'
import web3 from 'web3'
import { AccountData, ContractData, ContractForm } from 'drizzle-react-components'
import logo from '../../logo.png'
// import PropTypes from 'prop-types'

import drizzleOptions from '../../drizzleOptions'
import store from '../../store'

import { Drizzle, generateStore } from 'drizzle'
const drizzleStore = generateStore(drizzleOptions)
const drizzle = new Drizzle(drizzleOptions, drizzleStore)

class Home extends Component {

  constructor(props, context) {
    super(props)

    this.contracts = drizzle.contracts
    this.becomeDealerForTable = this.becomeDealerForTable.bind(this)
    this.startRound = this.startRound.bind(this)
    this.closeRound = this.closeRound.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.calcHash = this.calcHash.bind(this)

    this.state = {
      secretNumber: 0,
      hash: ""
    }
  }
  
  handleInputChange(event) {
    this.setState({ [event.target.name]: event.target.value })
  }

  becomeDealerForTable() {
    this.contracts.Casino.methods.becomeDealerForTable().send()
  }

  startRound() {
    this.contracts.Casino.methods.startRound(3).send()
  }

  closeRound() {
    this.contracts.Casino.methods.closeRound(3).send()
  }

  calcHash() {
    this.contracts.Casino.methods.calcHash(this.state.secretNumber).send().then(function(hash) {
      console.log("hash:" + hash);
    });
  }

  render() {
    return (
      <main className="container">
        <div className="pure-g">
          <div className="pure-u-1-1 header">
            <img src={logo} alt="drizzle-logo" />
            <h1>D-Casino</h1>
            <p>Lose money 24/7!</p>

            <br/><br/>
          </div>
        
          <div className="pure-u-1-1">
            <h2>Active Account</h2>
            <AccountData accountIndex="0" units="ether" precision="3" />

            <br/><br/>
          </div>

          <div className="pure-u-1-1">
            <h2>Exchange Chips in the Casino</h2>
            <p>1) Add the CAS token to MetaMask!</p>
            <p><strong>CAS Token Address</strong>: <ContractData contract="Casino" method="getChipTokenAddress" /></p>
            <p>2) Exchange ETH/CAS:</p>
            <p>You can exchange ETH for casino chips (CAS tokens) by sending ETH to the casino address (must be a multiple of the chip price). The casino will send you the CAS.</p>
            <p>You can exchange casino chips (CAS tokens) for ETH by sending CAS to the casino address. The casino will send you the ETH.</p>
            <p><strong>Chip Price</strong>: <ContractData contract="Casino" method="getChipPrice" /> Wei</p>
            <p><strong>Casino Address</strong>: <ContractData contract="Casino" method="getChipSwapAddress" /></p>
            <br/><br/>
          </div>

          <div className="pure-u-1-1">
            <h2>Table Dealer</h2>
            <p>Currently there is only one single table in our casino. The table dealer is responsible for starting and closing rounds.</p>
            {/* <p><strong>Stored Value</strong>: {storedData}</p> */}
            <p><strong>Current Table Dealer Address</strong>: <ContractData contract="Casino" method="getTableDealer" /></p>
            <form className="pure-form pure-form-stacked">
              {/* <input name="storageAmount" type="number" value={this.state.storageAmount} onChange={this.handleInputChange} /> */}
              <button className="pure-button" type="button" onClick={this.becomeDealerForTable}>Become Dealer for Table</button>
            </form>

            <br/><br/>

            <h3>Start and close round</h3>
            <p><strong>Current Phase</strong>: <ContractData contract="Casino" method="getPhase" /></p>
            <button className="pure-button" type="button" onClick={this.startRound}>Start Round</button>
            <br/><br/>
            <button className="pure-button" type="button" onClick={this.closeRound}>Close Round</button>
            {/* <ContractForm contract="Casino" method="startRound" labels={['Random number']} /> */}

            <br/><br/>
          </div>

          <div className="pure-u-1-1">
            <h2>Play!</h2>
            <p><strong>Table Address</strong>: <ContractData contract="Casino" method="getTableAddress" /></p>
            <p>In phase &quot;Players can place bets&quot; send CAS to the table address (the data field must contain the hash of "msg.sender and number").</p>
            <input name="secretNumber" type="number" value={this.state.secretNumber} onChange={this.handleInputChange} /><br/>
            <button className="pure-button" type="button" onClick={this.calcHash}>Calculate Hash</button><br/>
            <strong>Calculated Hash (send this as data with your CAS to the table address)</strong>: <br/>
            <p>In phase &quot;Players can reveal their numbers&quot; call reveal with your secret number:</p>
            <ContractForm contract="Casino" method="reveal"  labels={['Secret number']}/>
            <p>The winners will be calculated when the table dealer closes the round and will get payed out 2x the CAS they betted.</p>
            <br/><br/>
          </div>

          {/* <div className="pure-u-1-1">
            <h2>SimpleStorage</h2>
            <p>This shows a simple ContractData component with no arguments, along with a form to set its value.</p>
            <p><strong>Stored Value</strong>: <ContractData contract="SimpleStorage" method="storedData" /></p>
            <ContractForm contract="SimpleStorage" method="set" />

            <br/><br/>
          </div> */}

          {/* <div className="pure-u-1-1">
            <h2>TutorialToken</h2>
            <p>Here we have a form with custom, friendly labels. Also note the token symbol will not display a loading indicator. We've suppressed it with the <code>hideIndicator</code> prop because we know this variable is constant.</p>
            <p><strong>Total Supply</strong>: <ContractData contract="TutorialToken" method="totalSupply" methodArgs={[{from: this.props.accounts[0]}]} /> <ContractData contract="TutorialToken" method="symbol" hideIndicator /></p>
            <p><strong>My Balance</strong>: <ContractData contract="TutorialToken" method="balanceOf" methodArgs={[this.props.accounts[0]]} /></p>
            <h3>Send Tokens</h3>
            <ContractForm contract="TutorialToken" method="transfer" labels={['To Address', 'Amount to Send']} />

            <br/><br/>
          </div> */}

          {/* <div className="pure-u-1-1">
            <h2>Your Chips</h2>
            <p>Use the token to play in our casino (and get poor).</p>
            <p><strong>My Balance</strong>: <ContractData contract="CasinoToken" method="balanceOf" methodArgs={[this.props.accounts[0]]} /></p>
            <h3>Send Tokens</h3>
            <ContractForm contract="CasinoToken" method="transfer" labels={['To address of table', 'Amount to send', 'Your bet (black or red)']} />

            <br/><br/>
          </div> */}

          {/* <div className="pure-u-1-1">
            <h2>ComplexStorage</h2>
            <p>Finally this contract shows data types with additional considerations. Note in the code the strings below are converted from bytes to UTF-8 strings and the device data struct is iterated as a list.</p>
            <p><strong>String 1</strong>: <ContractData contract="ComplexStorage" method="string1" toUtf8 /></p>
            <p><strong>String 2</strong>: <ContractData contract="ComplexStorage" method="string2" toUtf8 /></p>
            <strong>Single Device Data</strong>: <ContractData contract="ComplexStorage" method="singleDD" />

            <br/><br/>
          </div> */}
        </div>
      </main>
    )
  }
}

export default Home
