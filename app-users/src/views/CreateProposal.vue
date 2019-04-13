<template>
  <div>
    <h1 class="display-1">
      Create proposal {{ progress }}
    </h1>
    <br>

    <v-stepper v-model="progress" vertical>
      <v-stepper-step :complete="Boolean(proposal.name) && Boolean(proposal.description)" step="1" editable>
        Basic Info 
        <small>Name, description</small>
      </v-stepper-step>

      <v-stepper-content step="1">
        <v-text-field
          v-model="proposal.name"
          label="Name"
          box
        />
        <v-textarea
          v-model="proposal.description"
          label="Description"
          box
        />
        <v-btn color="primary" @click="progress = 2">
          Continue
        </v-btn>
        <v-btn flat>
          Cancel
        </v-btn>
      </v-stepper-content>

      <v-stepper-step :complete="progress > 2" step="2">
        Configure analytics for this app
      </v-stepper-step>

      <v-stepper-content step="2">
        <v-card color="grey lighten-1" class="mb-5" height="200px" />
        <v-btn color="primary" @click="progress = 3">
          Continue
        </v-btn>
        <v-btn flat>
          Cancel
        </v-btn>
      </v-stepper-content>

      <v-stepper-step :complete="progress > 3" step="3" optional>
        Select an ad format and name ad unit
      </v-stepper-step>

      <v-stepper-content step="3">
        <v-card color="grey lighten-1" class="mb-5" height="200px" />
        <v-btn color="primary" @click="progress = 4">
          Continue
        </v-btn>
        <v-btn flat>
          Cancel
        </v-btn>
      </v-stepper-content>

      <v-stepper-step step="4">
        View setup instructions
      </v-stepper-step>
      <v-stepper-content step="4">
        <v-card color="grey lighten-1" class="mb-5" height="200px" />
        <v-btn color="primary" @click="progress = 1">
          Continue
        </v-btn>
        <v-btn flat>
          Cancel
        </v-btn>
      </v-stepper-content>
    </v-stepper>
  </div>
</template>

<script>
    // importing common function
    import mixin from '../libs/mixinViews'
    import Proposal from '../models/Proposal'

    export default {
        mixins: [mixin],

        data() {
            return {
                progress: 1,
                proposal: new Proposal,
                submitting: false, // true once the submit button is pressed
                successMessage: false, // true when the user has been registered successfully

                tmoConn: null, // contain the intervalID given by setInterval
                tmoReg: null, // contain the intervalID given by setInterval
                errorStr: null, // it shows the error message
            }
        },

        computed: {
            /**
             * It disables the submit button when the the name or userStatus are not filled
             * or the submit button is pressed or the connection with the blockchin is
             * not established.
             */
            disableSubmit() {
                return (
                    // !this.proposal.checkRequiredFields() ||
                    this.submitting ||
                    !this.blockchainIsConnected()
                )
            }
        },

        created() {
        },

        methods: {
            /**
             * Perform the registration of the proposal when the submit button is pressed.
             */
            async performSubmit() {
                this.submitting = true
                this.errorStr = null
                this.successMessage = false

                let account = await window.bc.getMainAccount()
                this.performUserRegistration(account)
            },

            /**
             * Show the form error.
             *
             * @param {object} err
             * @return {void}
             */
            showErrorMessage(err) {
                console.error(err)

                this.errorStr = null

                if (err) this.errorStr = err.toString()

                if (! this.errorStr) this.errorStr = 'Error occurred!'
            },

            /**
             * Perform the user registration cannling the smart contract
             * function registerUser.
             *
             * @param {string} address
             * @return {void}
             */
            performUserRegistration(address) {
                window.bc.contract().registerUser(
                    this.userName,
                    this.userStatus,
                    {
                        from: address,
                        gas: 800000
                    },
                    (err, txHash) => {
                        this.submitting = false

                        if (err) {
                            this.showErrorMessage(err)
                        }
                        else {
                            this.successMessage = true

                            // it emits a global event in order to update the top menu bar
                            Event.$emit('userregistered', txHash)

                            // the transaction was submitted and the user will be redirected to the
                            // profile page once the block will be mined
                            this.redirectWhenBlockMined()
                        }
                    }
                )
            },

            /**
             * Check if the user visitng this page is registered: if the user is already
             * registered he will be redirected to the Profile page.
             *
             * @return {void}
             */
            redirectIfUserRegistered() {
                this.tmoConn = setInterval(() => {
                    // checking first the connection
                    if (this.blockchainIsConnected()) {
                        // stopping the interval
                        clearInterval(this.tmoConn)

                        // calling the smart contract
                        this.isRegistered().then(res => {
                            if (res) {
                                // redirecting to the profile page
                                this.$router.push("profile")
                            }
                        })
                    }
                }, 500)
            },

            /**
             * Once the user submitted his registration this funciton checks every 1000 ms
             * if the registration is successfully. Once the user is registered he will be
             * redirected to the profile page.
             *
             * NOTE: in order to check if the user has been registered successfully the
             * function has to check several time because the block can take several
             * minutes to be mined (depending on the the blockchain you are using).
             *
             * @return {void}
             */
            redirectWhenBlockMined() {
                this.tmoReg = setInterval(() => {
                    if (this.blockchainIsConnected()) {
                        this.isRegistered()
                            .then(res => {
                                if (res) {
                                    // stopping the setInterval
                                    clearInterval(this.tmoReg)

                                    // redirecting the user to the profile page
                                    this.$router.push("profile")
                                }
                            })
                            .catch(error => this.showErrorMessage(error))
                    }
                }, 1000)
            }
        }
    }
</script>
