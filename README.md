# Ethereum and VueJS DApp

This is a simple decentralized application built using **Ethereum** blockchain (smart contracts in `contracts/`) and **Vue JS** for the front-end (in `app-users/`).

# Prerequisite
- NPM >5.8.0 (or better yarn)
- TRUFFLE >4.1.5
- Ganache or your private network
- Metamask: not mandatory but better if you want to act as different users

# Quick Installation
1) Clone the project into a folder of your choice (from here on **~/dapp**).
2) Start ganache (or your private blockchain, change the `--network` parameter accordingly).
3) Open the terminal (if you are using Windows you **must use the Power Shell**) in the folder **~/dapp** and run the command:
```sh
$ truffle --network ganache migrate --reset --compile-all
```
4) If the migration was successful, copy the compiled contracts **~/dapp/build/contracts/*.json** into the folder **~/dapp/app-users/src/assets/contracts/**
5) Open another terminal in the folder **~/dapp/app-users** and run the command:
```sh
$ yarn install
```
6) Once all the dependencies are installed run the command:
```sh
$ yarn run dev
```
If everything went fine, the terminal will display a message similar to:
```sh
DONE  Compiled successfully in 5166ms           15:54:53

Your application is running here: http://localhost:8080
```
7) Open the browser, go to the URL shown by your terminal and play with the DApp!

**NOTE:** if you want to act as different users, you have to install metamask in your browser, then import the accounts into metamask and finally change account on metamask in order to register a new user.

# Connect with Remix (for debugging)
1) Make sure that Ganache is running on Port 8545
2) Deploy the contract with

    truffle migrate --network NETWORK --reset

3) Truffle will return the address of the contract. For example "> contract address:    0x524BFAeeE766c7AEA06903207382Cc3ce3a67b72"
4) Start RemixIDE (https://remix.ethereum.org)
5) Select the Tab "Run" on the right side
6) Choose Environment "Web3 Provider" and confirm that you want to connect to the node
7) Paste the contract address in the field "At Address" and click on the Button "At Address"
8) You should now see the "Schwungrat" Contract in the "Deployed Categories" window and all available methods

App framework from: [DanieleFavi.com](https://www.danielefavi.com/create-your-blockchain-dapp-with-ethereum-and-vuejs/).
