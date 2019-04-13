<template>
  <div>
    <h1 class="title">
      Proposed procotols
      <v-btn @click="reloadList">
        <v-icon>refresh</v-icon>
        Reload from Blockchain
      </v-btn>
    </h1>
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
                proposals: null, // null indicates loading state
                tmoConn: null, // contain the intervalID given by setInterval
            }
        }, // end methods

        created() {
            // it tries to get the user list from the blockchian once
            // the connection is established
            this.tmoConn = setInterval(() => {
                this.getList()
                if (this.proposals != null) {
                    clearInterval(this.tmoConn) // stopping the interval
                }
            }, 1000)
        },

        methods: {
            /**
             * Get the list of the registered users once the connection to the
             * blockchain is established.
             */
            getList() {
                if (this.blockchainIsConnected()) {
                    // getting all the users from the blockchain
                    this.getAllProposals(userProfile => {
                        if (this.users == null)
                            this.users = []
                        this.users.push(userProfile)
                    })
                }
            },

            /**
             * It reloads the user list.
             */
            reloadList() {
                this.proposals = null // null indicates loading state
                this.getList()
            },

            /**
             * Get all users.
             */
            getAllProposals(callback) {
                // getting the total number of users stored in the blockchain
                // calling the method totalUsers from the smart contract
                window.bc.contract().totalUsers((err, total) => {
                    var tot = 0
                    if (total) tot = total.toNumber()

                    if (tot > 0) {
                        // getting the user one by one
                        for (var i=1; i<=tot; i++) {
                            window.bc.contract().getUserById.call(i, (error, userProfile) => {
                                callback(userProfile)
                            })
                        } // end for
                    } // end if
                }) // end totalUsers call
            }

        }
    }
</script>

<style>
</style>
