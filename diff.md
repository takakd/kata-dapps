# 変更点

## 実行環境

* macOS 10.15.5
* Node v15.0.1
* npm 7.0.3
* go 1.14.4
* Truffle v5.1.52 (core: 5.1.52)
* Solidity v0.5.16 (solc-js)
* Web3.js v1.2.9

## 内容

[Kindleリフロー版](https://www.amazon.co.jp/dp/B079JYHZY3/)に基づいて記載しています。  
対象はコントラクト実装に関するChapter6から8です。  
Solidity構文に関する7.2から7.5は対象外です。

### 6.1.4.3: Gethの初期化処理

次のエラーが出ました。

```shell
Fatal: Failed to write genesis block: unsupported fork ordering: eip150Block not enabled, but eip155Block enabled at 0
```

6.1.4.1の`genesis.json`のフォーマットが変わったので、次のように変更します。

```json
{
  "config": {
    "chainId": 33,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0
  },
  "alloc": {},
  "coinbase": "0x0000000000000000000000000000000000000000",
  "difficulty": "0x20000",
  "extraData": "",
  "gasLimit": "0x2fefd8",
  "nonce": "0x0000000000000042",
  "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
```

**Ref:**

* https://github.com/ethereum/go-ethereum/blob/feeccdf4ec1084b38dac112ff4f86809efd7c0e5/params/config.go#L71  

### 6.1.5.8: ロックの解除

`personal.unlockAccount`でエラーがでました。

```shell
GoError: Error: account unlock with HTTP access is forbidden at web3.js:6347:37(47)
        at native
        at <eval>:1:24(6)
```

6.1.4.6のgeth起動コマンドに`--allow-insecure-unlock`を追加すると実行可能になります。

```shell
geth --networkid "33" --nodiscover --datadir $DATA_DIR --rpc --rpcaddr "localhost" --rpcport "8545" --rpccorsdomain "*" --rpcapi "eth,net,web3,personal" \
    --allow-insecure-unlock \
    --targetgaslimit "20000000" console 2>> ${DATA_DIR}/error.log
```

unlockはデフォルトで機能OFFに変更されたようです。

**Ref:**

* https://github.com/ethereum/go-ethereum/pull/17037  
* https://github.com/ethereum/go-ethereum/issues/19507#issuecomment-487453981  

### 7.1.2.2: SimpleStorage.sol

Solidityのバージョンアップで記述方法が変わったので、次のように変更します。

```sol
// remix IDEサンプルsolidityコードのバージョンに合わせる
pragma solidity >=0.4.22 <0.7.0;

contract SimpleStorage {
    uint storedData;

    // publicが必要
    function set(uint x) public {
        storedData = x;
    }

    // publicが必要、constant廃止、viewに変える
    function get() public view returns (uint) {
        return storedData;
    }
}
```

### 7.1.2.9: SimpleStorageOwner.sol

コンストラクタの書式が変わったので、次のように変更します。

```sol
pragma solidity >=0.4.22 <0.7.0;

contract SimpleStorageOwner {
    uint storedData;
    address owner;

    // コンストラクタの記述が、construct() publicに変更
    constructor() public {
        owner = msg.sender;
    }
    // ...
}
```

**Ref:**  

* https://solidity.readthedocs.io/en/v0.5.3/050-breaking-changes.html?highlight=constructor

### 8.1.6.2: MetaCoin.sol

Solidityのバージョンアップで記述方法が変わったのですが、次のコマンドで取得するコードを実行すればOKでした。

```shell
$ truffle unbox metacoin
```

### 8.1.6.8: MetaCoinを変数に保存する

```shell
truffle(develop)> m = await MetaCoin.at("<address>")
```

`at`は`Promise`を返すようになったので`await` or コールバックで受け取ります。

**Ref:**

* https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts#use-a-contract-at-a-specific-address

また、8.1.6.7の出力形式が変わったので、コントラクトのアドレスは`contract address:`の値を使用します。

```shell
Replacing 'MetaCoin'
   --------------------
   > transaction hash:    0xdf84b6dc0debb81e22284bbc8b214c27a9c5b18b76e5ea9baef60c33bc3916b1
   > Blocks: 0            Seconds: 0
   > contract address:    0x1dA8f51aad5Eb8B2997AA9dc0FFD838900A2CA1C
   > block number:        9
```

### 8.1.6.9: getBalanceの呼び出し

`web3.eth.getAccounts`は`Promise`を返すようになったので`await` or コールバックで受け取ります。  
8.1.6.11 - 8.1.6.17で`web3.eth.getAccounts`を使用しているところも同様に`accounts[<index>]`を指定します。

```shell
truffle(develop)> accounts = await web3.eth.getAccounts()
truffle(develop)> m.getBalance(accounts[0])
```

**Ref:**
* https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts#making-a-transaction

### 8.2.2.1: OpenZeppelinのインストール

zeppelin-solidityはdeprecatedになりました。代わりにopenzeppelin-contractsを使用します。

```shell
$ npm init -f 
$ npm install @openzeppelin/contracts
```

**Ref:**

* https://www.npmjs.com/package/zeppelin-solidity

### 8.2.3.1: トークンのコントラクト

openzeppelin-contractsを使用するため記述が変わります。次のように変更します。

```sol
pragma solidity >=0.5.16 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// https://docs.openzeppelin.com/contracts/2.x/erc20-supply
contract DappsToken is ERC20 {
    string public name = "Dappstoken";
    string public symbol = "DTKN";
    uint public decimals = 18;

    constructor(uint256 initialSupply) public {
        _mint(msg.sender, initialSupply);

        // 8.3.2.15を実行するときは10e18を追加
        //_mint(msg.sender, initialSupply * (10 ** 18));
    }
}
```

### 8.2.4.3: マイグレーションの実行

8.1.6.8同様に`await`を使用します。

```shell
truffle(develop)> dappsToken = await DappsToken.at(DappsToken.address)
```

### 8.3.1.3: truffle.js

`networks.development.network_id`はgethの`run`コマンドで指定している`--networkid`と同じ値を指定します。

### 8.3.2.7: MateMask Ether Faucetでのトランザクション発行

エラーが出てEtherを取得できませんでした。取得は別サイトでも可能なのでそれを利用します。いくつかあるようですが以下のサイトで取得できました。

[Ethereum Faucet - Ropsten](https://faucet.dimensions.network/)

**Ref:**
* https://github.com/MetaMask/metamask-extension/issues/5439#issuecomment-716547644

### 8.3.2.11: truffle.jsにRopstenを設定

truffleのバージョンアップで記述方法が変わったので、npmモジュールを追加して、コードを次のように変更します。

**@truffle/hdwallet-providerモジュールの追加**

truffle-config.jsで使用するモジュールを追加します。

```shell
$ npm install @truffle/hdwallet-provider
```

**.secret**

認証情報を`.secret`に定義します。MetaMaskで作成したアカウントのニーモニックをスペース区切りで入力します。

```ini
<nemonic1> <nemonic2> <nemonic3> ...
```

**truffle-config.js**

ファイル名が`truffle.js`から`truffle-config.js`に変わりました。  
`HDWalletProvider`に渡すURLに`accessToken`ではなく`PROJECT SECRET`を渡します。`PROJECT SECRET`は[Infura](https://infura.io)で作成したプロジェクトで取得できます。

```js
const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  networks: {
    development: {
     host: "localhost",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "33",       // Any network (default: none)
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/<Infura PROJECT SECRET>`),
      network_id: 3,       // Ropsten's id
      gas: 5500000,        // Ropsten has a lower block limit than mainnet
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
  },
  ...
};
```

### 8.3.2.14, 8.3.2.15

`migrate`で`initialSupply`のオーバーフローエラーが出るので、Contract側で1e18するように変更します。

**2_deploy_dapps_token.js**

```js
const DappsToken = artifacts.require("./Dappstoken.sol");

module.exports = function(deployer){
    const initialSupply = 1000;
    // ここでは1000を渡す
    deployer.deploy(DappsToken, initialSupply, {
        gas: 2000000
    });
}
```

**DappsToken.sol**

```sol
pragma solidity >=0.5.16 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// https://docs.openzeppelin.com/contracts/2.x/erc20-supply
contract DappsToken is ERC20 {
    string public name = "Dappstoken";
    string public symbol = "DTKN";
    uint public decimals = 18;

    constructor(uint256 initialSupply) public {
        // ここでdecimalsに合わせ、1e18する
        _mint(msg.sender, initialSupply * (10 ** 18));
    }
}
```

### 8.3.2.20: 変数にトークンを設定

overflowで失敗するので`web3.utils.toBN`で変換した値を渡します。

```shell
truffle(ropsten)> d.transfer(“<receiver address>”, web3.utils.toBN(1e18))
```

### 8.3.2.21: 残高の確認

残高が`word`に値を分割して表示されます。次のように表示すると一つの値で表示できます。

```shell
truffle(ropsten)> d.totalSupply().then(result => {console.log(result.toString())})
```