<template>
  <!-- <v-navigation-drawer app /> -->
  <v-toolbar app>
    <!-- <v-toolbar-side-icon /> -->
    <v-icon>device_hub</v-icon>
    <v-toolbar-title>Schwungrat</v-toolbar-title>

    <v-spacer />

    <v-btn flat to="/create">
      <v-icon>add</v-icon>
      Create
    </v-btn>
    <v-btn flat to="/">
      <v-icon>list</v-icon>
      Proposed protocols
    </v-btn>

    <v-spacer />

    <v-btn icon to="/account">
      <v-icon>account_circle</v-icon>
    </v-btn>

    <!-- <template v-slot:extension>
        <v-toolbar-items>
          <v-btn
            flat
            to="/create"
          >
            Create
          </v-btn>
        </v-toolbar-items>
      </template> -->
  </v-toolbar>

  <!-- <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <ul class="navbar-nav">
      <router-link
        tag="li"
        class="nav-link"
        to="/"
        exact
      >
        <a>Statuses</a>
      </router-link>

      <router-link
        v-show="userIsRegistered"
        tag="li"
        class="nav-link"
        to="/profile"
        exact
      >
        <a>Profile</a>
      </router-link>

      <router-link
        v-show="!userIsRegistered"
        tag="li"
        class="nav-link"
        to="/register"
        exact
      >
        <a><strong>Register</strong></a>
      </router-link>

      <li class="nav-link" />
      <li class="nav-link">
        <strong :class="connectedClass">
          {{ bcConnected ? 'Connected' : 'Not Connected' }}
        </strong>
      </li>
    </ul>
  </nav> -->
</template>

<script>
    // importing common function
    import mixin from '../libs/mixinViews'

    export default {
        mixins: [mixin],

        data() {
            return {
                tmoConn: null, // contain the intervalID given by setInterval
                tmoReg: null, // contain the intervalID given by setInterval
                connectedClass: 'red', // vuetify class for the connection status (red when not connected, green when connected)
                userIsRegistered: false, // true when the user that is visiting the page is registered
            }
        },

        created() {
            // when the event userregistered is fired (from the view Register.vue)
            // it runs the function checkUntilUserIsRegistered
            Event.$on('userregistered', this.checkUntilUserIsRegistered)

            this.checkUserIsRegistered()
        },

        methods: {
            /**
             * It checks if the visiting user is regitered calling every 500ms the function isRegistered
             * from the smart contract until the connection with the smart contract is established.
             */
            checkUserIsRegistered() {
                this.tmoConn = setInterval(() => {
                    // checking first if the connection with the blockchain is established
                    if (this.blockchainIsConnected()) {
                        // stopping the setInterval
                        clearInterval(this.tmoConn)

                        // showing the connected message on the top bar and setting the class too
                        this.connectedClass = 'green'

                        this.isRegistered()
                            .then(res => this.userIsRegistered = res)
                            .catch(error => console.log(error))
                    }
                }, 500)
            },

            /**
             * Check if the user is registered calling the function of the smart contract isRegistered.
             * This function is used when the user is signing up.
             * The difference with the previous function is:
             *      - the function checkUserIsRegistered tries to check if the user is registered
             *        until the connection with the blockchain is established.
             *      - the function checkUntilUserIsRegistered tries to check if the user is registered
             *        until the user is registered.
             *
             * NOTE: in order to check if the user has been registered successfully the function has to check
             * several time because the block can take several minutes in order to be mined (depending on the
             * configuration of the blockchain you are using).
             */
            checkUntilUserIsRegistered() {
                this.tmoReg = setInterval(() => {
                    if (this.blockchainIsConnected()) {
                        this.isRegistered()
                            .then((res) => {
                                console.error("isRegistered result: ", res)
                                if (res) {
                                    // stopping the setInterval
                                    clearInterval(this.tmoReg)

                                    this.userIsRegistered = res
                                }
                            })
                            .catch(error => console.error("Failed isRegistered check: ", error))
                    }
                }, 1000)
            }
        }
    }
</script>

<style>
</style>
