import Home from './Home'
import { drizzleConnect } from 'drizzle-react'
import PropTypes from 'prop-types'
import { Drizzle, generateStore } from 'drizzle'

// May still need this even with data function to refresh component on updates for this contract.
const mapStateToProps = state => {
  return {
    accounts: state.accounts,
    SimpleStorage: state.contracts.SimpleStorage,
    TutorialToken: state.contracts.TutorialToken,
    Casino: state.contracts.Casino,
    Table: state.contracts.Table,
    drizzleStatus: state.drizzleStatus
  }
}

var HomeContainer = drizzleConnect(Home, mapStateToProps);

// HomeContainer.contextTypes = {
//   drizzle: PropTypes.object
// }

export default HomeContainer
