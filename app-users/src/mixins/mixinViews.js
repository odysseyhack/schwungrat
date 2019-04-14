import BcExplorer from '../libs/BcExplorer'
import SchwungratContract from '../assets/contracts/Schwungrat.json'

export default {
    data() {
        return {
            bcConnected: false, // true when the connection with the blockchain is established, plus the contract ABI + address is correctli initialized
            bcConnectionError: false,
            errorConnectionMessage: null,
            bcSmartContractAddressError: false,
            submitting: false, // true once the submit button is pressed
            submitDone: false, // true when the submit process completed
        }
    },

    created() {
        this.init()
    },

    methods: {
        /**
         * Initialize the BcExplore object (this means the connection with the
         * blockchin and initialise the contracts).
         *
         * @return {void}
         */
        init() {
            // when this file is imported to other component it checks if the BcExplorer
            // is instatiated.
            if (window.bc == undefined) {
                window.bc = new BcExplorer

                // connecting to the blockchain and intializing the smart contract
                window.bc.initWithContractJson(SchwungratContract, 'http://127.0.0.1:7545') //TODO: get blockchain URL from config
                    .then((error) => {
                        // handling the connection error
                        if (error) {
                            this.bcConnected = false
                            this.showConnectionErrorMessage(error)
                        } else {
                            this.bcConnectionError = false
                            this.bcConnected = this.blockchainIsConnected()
                            // calling a smart contract function in order to check the contract address
                            // is correct. NOTE: here you might be connected successfully.
                            // TODO: the check of the smart contract address validity it should be BcExplorer duty
                            /* this.isRegistered()
                                .then(_res => {
                                    this.bcConnectionError = false
                                    this.bcConnected = this.blockchainIsConnected()
                                })
                                .catch(error => {
                                    this.showConnectionErrorMessage(error)
                                    this.bcSmartContractAddressError = true
                                }) */
                        }
                    })
                    .catch(error => this.showConnectionErrorMessage(error))
            } // end if (window.bc == undefined)
        },

        /**
         * Check if the user is registered.
         *
         * @return {Promise}
         */
        isRegistered() {
            return new Promise((resolve, reject) => {
                window.bc.getMainAccount()
                // .then(account => {
                //     window.bc.contract().isRegistered({ from: account }, (error, res) => {
                //         if (error) reject(error)

                    //         resolve(res)
                    //     })
                    // })
                    .catch(error => {
                        console.error("Failed to get main account:", error)
                        reject(error)
                    })
            })
        },

        /**
         * Show the conntection error message on top of the main content.
         *
         * @param {object} error|null
         * @return {void}
         */
        showConnectionErrorMessage(error=null) {
            this.bcConnectionError = true

            if (error) console.log(error)

            if (error && error.message) {
                this.errorConnectionMessage = error.message
            }
        },

        /**
         * Check if the connection with the blockchain is established and if the smart
         * contract ABI + address are correctly initialized.
         *
         * @return {boolean}
         */
        blockchainIsConnected() {
            this.bcConnected = ((window.bc != undefined) && window.bc.isConnected())

            return this.bcConnected
        },

        // Callback definitions for safeAsyncContractCall
        /**
         * Passed to web3.eth.Contract's method call.
         *
         * @callback safeCallback
         * @param error
         * @param data
         */
        /**
         * Will be called synchronously to kick off the contract call using the safeCallback.
         *
         * @callback contractCaller
         * @param {safeCallback} safeCallback
         */
        /**
         * Will be called with the actual response. Should return result or throw exception.
         *
         * @callback dataCallback
         * @param {data} data The actual data returned by the contract call
         * @returns final result
         * @throws Any exception - will be used to reject the final promise
         */
        /**
         * Wrapper function to asynchronously call a contract method.
         * @param {string} description For logging
         * @param {contractCaller} contractCaller For passing it to web3 as (error, data) callback
         * @param {dataCallback} dataCallback Will be called with the actual response.
         *        Should return result or throw exception. (if omitted, Promise will just return data)
         * @returns {Promise}
         */
        safeAsyncContractCall(description, contractCaller, dataCallback) {
            return new Promise((resolve, reject) => {
                contractCaller((error, data) => {
                    if (error) {
                        reject("Failed [" + description + "]: " + error)
                    } else {
                        try {
                            if (dataCallback) {
                                resolve(dataCallback(data))
                            } else {
                                resolve(data)
                            }
                        } catch(exc) {
                            reject("Failed [" + description + "]: " + exc)
                        }
                    }
                })
            })
        },

        /**
         * Transform the parameter from bytes to string.
         *
         * @param {string} bytesStr
         * @return {string}
         */
        toAscii(bytesStr) {
            return window.bc.toAscii(bytesStr)
        },

        /**
         * Transform a timestamp number to date.
         *
         * @param {numeric} bytesStr
         * @return {string}
         */
        toDate(timestamp) {
            return new Date(timestamp * 1000)
        }
    }
}
