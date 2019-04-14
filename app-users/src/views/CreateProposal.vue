<template>
  <div>
    <h1 class="display-1">
      Submit protocol
    </h1>
    <br>
    <p>
      Create a draft to be submitted to the platform.<br>
      Only the basic fields are mandatory.
    </p>

    <v-stepper v-model="progress" vertical>
      <v-stepper-step :rules="[() => progress == 1 || minimalRequirementsMet]" :complete="minimalRequirementsMet" step="1" editable>
        Basic Info 
        <small>Name*, Short description*</small>
      </v-stepper-step>

      <v-stepper-content step="1">
        <v-text-field
          v-model="protocol.name"
          label="Name"
          box
        />
        <v-textarea
          v-model="protocol.description"
          label="Short description"
          box
        />
        <v-btn color="primary" @click="progress = 2">
          Continue
        </v-btn>
        <v-btn depressed
               :disabled="!minimalRequirementsMet"
               @click="performSubmit()"
        >
          <v-icon>check</v-icon>
          Submit minimal draft
        </v-btn>
      </v-stepper-content>

      <v-stepper-step :complete="progress > 2" step="2" editable>
        Massive Transformational Purpose (MTP)* 
      </v-stepper-step>

      <v-stepper-content step="2">
        <v-textarea
          v-model="protocol.mtp"
          label="Massive Transformational Purpose"
          box
        />        
        <v-btn color="primary" @click="progress = 3">
          Continue
        </v-btn>
        <v-btn flat @click="progress -= 1">
          Back
        </v-btn>
      </v-stepper-content>

      <v-stepper-step :complete="progress > 3" step="3" optional editable>
        Select up to 5 major problems, the protocol should solve
      </v-stepper-step>

      <v-stepper-content step="3">
        <template>
          <v-layout row>
            <v-flex xs3>
              <v-checkbox label="Lorem" /><v-btn color="info">
                Info
              </v-btn>
            </v-flex>
          </v-layout>
        </template>
        <v-btn color="primary" @click="progress = 4">
          Continue
        </v-btn>
        <v-btn flat @click="progress -= 1">
          Back
        </v-btn>
      </v-stepper-content>

      <v-stepper-step step="4" editable>
        Implementation cost
      </v-stepper-step>
      <v-stepper-content step="4">
        <v-text-field
          v-model="protocol.totalImplementationCost"
          label="Implementation Cost"
          prefix="ETH"
        />
        <v-btn :disabled="!minimalRequirementsMet" color="primary" @click="performSubmit()">
          Submit Protocol
        </v-btn>
        <v-btn flat @click="progress -= 1">
          Back
        </v-btn>
      </v-stepper-content>
    </v-stepper>
    <!-- // END STEPPER -->

    <!-- Save button -->
    <v-fab-transition>
      <v-btn
        v-show="submitAvailable"
        fab fixed bottom right
        color="green"
        @click="performSubmit()"
      >
        <v-icon>check</v-icon>
      </v-btn>
    </v-fab-transition>

    <!-- Saving dialog -->
    <v-dialog
      :value="submitting || submitDone"
      persistent
      width="300"
    >
      <v-card
        :color="submitDone ? 'green' : 'primary'"
        dark
      >
        <v-card-text v-if="!submitDone">
          Saving protocol to Blockchain
          <v-progress-linear
            indeterminate
            color="white"
            class="mb-0"
          />
        </v-card-text>
        <v-card-text v-else>
          <v-icon>check</v-icon> Saved successfully!
        </v-card-text>
        <v-card-actions>
          <v-btn v-if="submitDone" to="/">
            Go to protocol
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
    // importing common function
    import mixin from '../mixins/mixinViews'
    import Protocol from '../models/Protocol'

    export default {
        mixins: [mixin],

        data() {
            return {
                progress: 1,
                protocol: new Protocol,
                submitting: false, // true once the submit button is pressed
                submitDone: false, // true when the submit process completed

                tmoConn: null, // contain the intervalID given by setInterval
                tmoReg: null, // contain the intervalID given by setInterval
                errorStr: null, // it shows the error message
            }
        },

        computed: {
            minimalRequirementsMet() {
                return Boolean(this.protocol.name) && Boolean(this.protocol.description)
            },

            /**
             * It disables the submit button when the the name or userStatus are not filled
             * or the submit button is pressed or the connection with the blockchain is
             * not established.
             */
            submitAvailable() {
                return (
                    this.progress > 1 &&
                    this.minimalRequirementsMet &&
                    !this.submitting &&
                    this.blockchainIsConnected()
                )
            }
        },

        created() {
        },

        methods: {
            /**
             * Perform the registration of the protocol when the submit button is pressed.
             */
            performSubmit() {
                if (!this.submitAvailable) {
                    alert("Submit not available")
                    return
                }
                this.submitting = true
                this.errorStr = null
                this.submitDone = false

                try {
                    window.bc.contract().createProtocolProposal(
                        this.protocol.name,
                        this.protocol.description,
                        this.protocol.totalImplementationCost,
                        (error, newId) => {
                            if (error) {
                                alert("Failed to create protocol: " + error)
                                this.submitting = false
                            } else {
                                this.submitting = false
                                this.submitDone = true
                                console.log("Created: " + newId)
                            }
                        })
                } catch(exc) {
                    this.submitting = false
                    this.showError("Failed to create proposal", exc)
                }
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
                            .catch(error => this.showError(error))
                    }
                }, 1000)
            }
        }
    }
</script>
