<template>
  <div>
    <h1 class="display-2">
      Proposed procotols {{ protocolCount }}
      <v-btn @click="reloadList">
        <v-icon>refresh</v-icon>
        Reload from Blockchain
      </v-btn>
    </h1>

    <li>
      <ol v-for="protocol in protocols" :key="protocol.id">
        <b>{{ protocol }}</b>
      </ol>
    </li>
  </div>
</template>

<script>
    // importing common function
    import mixin from '../libs/mixinViews'

    /**
     * List view component: this component shows list of the registered users
     * and their statuses.
     */
    export default {
        mixins: [mixin],

        data() {
            return {
                protocolCount: null, // null = not loaded
                protocols: null, // null = not loaded
                tmoConn: null, // contain the intervalID given by setInterval
            }
        }, // end methods

        created() {
            // it tries to get the user list from the blockchian once
            // the connection is established
            this.tmoConn = setInterval(() => {
                if (this.blockchainIsConnected()) {
                    // getting all the users from the blockchain
                    this.loadProtocols()
                    clearInterval(this.tmoConn) // stopping the interval
                }
            }, 1000)
        },

        methods: {
            /**
             * It reloads the user list.
             */
            reloadList() {
                this.protocols = null // null = loading
                this.protocolCount = null
                this.loadProtocols()
            },

            /**
             * Get all users.
             */
            loadProtocols() {
                // getting the total number of users stored in the blockchain
                // calling the method totalUsers from the smart contract
                window.bc.contract().totalProtocols((error, total) => {
                    if (error) {
                        alert(error)
                    } else {
                        if (!total) {
                            console.error("Falsy total returned:", typeof total, total)
                            alert("Falsy total " + total)
                        } else {
                            this.protocolCount = total.toNumber()
                            this.protocols = []

                            if (this.protocolCount > 0) {
                                // fetch protocols one by one
                                for (var i=1; i <= this.protocolCount; i++) {
                                    console.log("Loading protocol: " + i)
                                    let id = i
                                    window.bc.contract().getProtocolById(id, (error, protocol) => {
                                        if (error) {
                                            alert("Failed to load protocol " + id + ":\n" + error)
                                        } else {
                                            console.log("Loaded protocol:", protocol)
                                            this.protocols.push(protocol)
                                        }
                                    })
                                } // end for
                            } // end if
                        }
                    }
                }) // end totalUsers call
            }

        }
    }
</script>

<style>
</style>
