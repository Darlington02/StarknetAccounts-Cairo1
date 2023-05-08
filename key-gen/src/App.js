import logo from './logo.svg';
import './App.css';
import {
  ec,
  stark,
} from "starknet";

const privKey = stark.randomAddress();
const starkKeyPair = ec.getKeyPair(privKey);
const starkKeyPub = ec.getStarkKey(starkKeyPair);

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Public key: {starkKeyPub}
        </p><br />
        <p>
          Private key: {privKey}
        </p>
        <a
          className="App-link"
          href=""
          target="_blank"
          rel="noopener noreferrer"
        >
          Generate Key pairs
        </a>
      </header>
    </div>
  );
}

export default App;