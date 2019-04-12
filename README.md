# Ethereum and VueJS DApp

This is a simple decentralized application built using **Ethereum** blockchain (smart contracts in `contracts/`) and **Vue JS** for the front-end (in `app-users/`).

# Prerequisite
- NPM >5.8.0 (or better yarn)
- TRUFFLE >4.1.5
- Ganache or your private network
- Metamask: not mandatory but better if you want to act as different users

# Quick Installation
1) Clone the project into a folder of your choice (from here on **~/dapp**).
2) Start ganache (or your private blockchain).
3) Open the terminal (if you are using Windows you **must use the Power Shell**) in the folder **~/dapp** and run the command:
```sh
$ truffle console --network ganache
```
4) If ganache is running you should be inside the truffle console; now run the following command in the truffle console:
```sh
> migrate --reset --compile-all
```
5) If the migration was successful, copy the file **~/dapp/build/contracts/Users.json** into the folder **~/dapp/app-users/src/assets/**
6) Open another terminal in the folder **~/dapp/app-users** and run the command:
```sh
$ yarn install
```
7) Once all the dependencies are installed run the command:
```sh
$ yarn run dev
```
If everything went fine, the terminal will display a message similar to:
```sh
DONE  Compiled successfully in 5166ms           15:54:53

Your application is running here: http://localhost:8080
```
8) Open the browser, go to the URL shown by your terminal and play with the DApp!

**NOTE:** if you want to act as different users, you have to install metamask in your browser, then import the accounts into metamask and finally change account on metamask in order to register a new user.

App framework from: [DanieleFavi.com](https://www.danielefavi.com/create-your-blockchain-dapp-with-ethereum-and-vuejs/).
