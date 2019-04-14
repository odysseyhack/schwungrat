import AmountPicker from ''

<template>
  <div>
    <!-- Toolbar -->
    <v-layout row wrap>
      <!-- layout and flex elements move the reload button to the right -->
      <v-flex>
        <h1 class="display-2">
          Proposed protocols
        </h1>
      </v-flex>
      <v-flex class="text-xs-right">
        <v-btn color="green" large class="font-weight-bold"
               to="/create"
        >
          Create New
          <v-icon>add</v-icon>
        </v-btn>
        <v-btn>
          Filter
          <v-icon>filter_list</v-icon>
        </v-btn>
        <v-btn :loading="loading" @click="reloadList">
          Reload
          <v-icon>refresh</v-icon>
        </v-btn>
      </v-flex>
    </v-layout><br>

    <!-- Protocol list -->
    <v-data-iterator
      v-if="protocols != null"
      :items="protocols"
      content-tag="v-layout"
      row
      wrap
    >
      <!-- PROTOCOL CARD -->
      <template v-slot:item="props">
        <v-flex xs12 md6 lg4>
          <v-hover>
            <v-card
              slot-scope="{ hover }"
              :class="`elevation-${hover ? 12 : 2}`"
            >
              <v-card-title>
                <h4>{{ props.item.name }}</h4>
                <v-spacer />
                <span class="font-weight-bold text-uppercase">{{ props.item.status }}</span>
              </v-card-title>
              <v-divider />

              <v-card-text class="pb-0">
                <p>
                  {{ props.item.description }}
                </p>
                <p v-if="props.item.purpose">
                  <span class="subheading">Purpose</span><br>
                  {{ props.item.purpose }}
                </p>

                <strong>Funding:</strong> Wei {{ props.item.balance }} / {{ props.item.totalImplementationCost }}
              </v-card-text>
              <v-progress-linear
                color="info"
                height="10"
                :value="props.item.fundingProgress() * 100"
                class="mb-0"
              />

              <v-card-actions>
                <v-btn flat color="success" @click="openFundingDialog(props.item)">
                  <v-icon>arrow_upward</v-icon>
                  Fund
                </v-btn>
                <v-btn flat>
                  Details
                </v-btn>
                <v-spacer />
                <v-btn icon>
                  <v-icon
                    color="pink"
                    @click="toggleFavorite(props.item)"
                    v-text="props.item.favored ? 'favorite' : 'favorite_border'"
                  />
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-hover>
        </v-flex>
      </template> <!-- // END PROTOCOL CARD -->

      <template v-slot:no-data>
        <v-alert v-show="!loading" value="true" color="warning">
          No protocols found
        </v-alert>
      </template>
    </v-data-iterator>

    <v-dialog v-if="fundingDialog" v-model="fundingDialog" persistent max-width="600px">
      <v-card class="pa-2">
        <v-card-title>
          <h6 class="title">
            <strong>Fund protocol:</strong> {{ fundingDialog.target.name }}
          </h6>
        </v-card-title>
        <v-card-text v-if="!submitting && !submitDone">
          <v-layout row wrap>
            <v-flex grow>
              <v-slider
                v-model="fundingDialog.amount"
                label="Wei:"
                thumb-color="green"
                thumb-label="always"
                max="100"
              />
            </v-flex>
            <v-flex shrink ml-4>
              <v-text-field
                v-model="fundingDialog.amount"
                class="mt-0"
                type="number"
                style="max-width:100px"
              />
            </v-flex>
          </v-layout>
        </v-card-text>
        <v-card-text v-else-if="submitting && !submitDone">
          Sending funds
          <v-progress-linear
            indeterminate
            class="mb-0"
          />
        </v-card-text>
        <v-card-text v-else>
          <v-icon>check</v-icon> Sent successfully!
        </v-card-text>
        <v-card-actions v-if="!submitDone">
          <v-btn color="primary" flat @click="fundingDialog = null">
            Cancel
          </v-btn>
          <v-spacer />
          <v-btn color="success" @click="performFunding()">
            Perform funding
          </v-btn>
        </v-card-actions>
        <v-card-actions v-else>
          <v-btn @click="fundingDialog = null; submitDone = false;">
            Dismiss
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
    import BigNumber from 'bignumber.js'
    import _ from 'lodash'

    /**
     * List view component: this component shows list of the registered users
     * and their statuses.
     */
    export default {
        mixins: [mixin],

        data() {
            return {
                loading: true,
                protocolCount: null, // null = not loaded
                protocols: null, // null = not loaded
                tmoConn: null, // contain the intervalID given by setInterval

                fundingDialog: null,
            }
        }, // end methods

        computed: {
            favorites: function() {
                try {
                    return JSON.parse(this.$localStorage.get('favorites', "[]"))
                } catch (exc) {
                    alert("Failed to read favorites")
                    return []
                }
            }
        },

        created() {
            // it tries to get the user list from the blockchian once
            // the connection is established
            this.tmoConn = setInterval(() => {
                if (this.blockchainIsConnected()) {
                    // getting all the users from the blockchain
                    this.reloadList()
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
                _.defer(async () => {
                    try {
                        this.protocolCount = await this.fetchProtocolCount()
                        this.protocols = await this.fetchProtocols()
                        this.protocols = _.sortBy(this.protocols, [(p) => 1-p.fundingProgress()])
                    } catch(exc) {
                        console.error("Failed to fetch protocols:", exc)
                        alert("Failed to fetch protocols: " + exc)
                    } finally {
                        this.loading = false
                    }
                })
            },

            /**
             * Get protocol total count from EVM
             */
            fetchProtocolCount() {
                return new Promise((resolve, reject) => {
                    // getting the total number of users stored in the blockchain
                    // calling the method totalUsers from the smart contract
                    this.loading = true
                    window.bc.contract().totalProtocols(async (error, total) => {
                        if (error) {
                            reject(error)
                        } else {
                            if (!total) {
                                console.error("Falsy total returned:", typeof total, total)
                                reject("Falsy total " + total)
                            } else {
                                resolve(total.toNumber())
                            }
                        }
                    }) // end totalUsers call
                })
            },

            /**
             * Get all protocols from EVM
             */
            fetchProtocols() {
                let promises = []
                if (this.protocolCount > 0) {
                    // fetch protocols one by one
                    for (var id=1; id <= this.protocolCount; id++) {
                        console.log("Loading protocol: " + id)
                        promises.push(this.safeAsyncContractCall(
                            "Load protocol " + id,
                            (safeCallback) => {
                                window.bc.contract().getProtocolById(id, safeCallback) 
                            },
                            (data) => {
                                console.debug("Fetched protocol:", data)
                                let protocol = Protocol.fromContractReturn(data)
                                protocol.favored = this.favorites.includes(protocol.id)
                                console.log("Loaded protocol:", protocol)
                                return protocol
                            })
                        )
                    } // end for
                }
                return Promise.all(promises)
            },

            toggleFavorite(protocol) {
                let favorites = this.favorites // copy of computed property
                if (protocol.favored) {
                    _.pull(favorites, protocol.id)
                    protocol.favored = false
                } else {
                    favorites.push(protocol.id)
                    protocol.favored = true
                }
                this.$localStorage.set('favorites', JSON.stringify(favorites))
            },

            /** Open funding dialog */
            openFundingDialog(protocol) {
                this.fundingDialog = {
                    target: protocol, 
                    amount: new BigNumber(10)
                }
            },

            /** Send fund of given amount to protocol. */
            performFunding() {
                this.submitting = true
                this.submitDone = false

                this.safeAsyncContractCall(
                    "Fund protocol " + this.fundingDialog.target.id + " with " + this.fundingDialog.amount,
                    (safeCallback) => {
                        window.bc.contract().fundProtocol(this.fundingDialog.target.id, {value: this.fundingDialog.amount}, safeCallback) 
                    })
                    .then((data) => {
                        console.log("Fund response:", data)
                        this.submitting = false
                        this.submitDone = true
                        this.reloadList()
                    })
                    .catch((error) => {
                        this.submitting = false
                        alert(error)
                    })
                
                        
            }
        }
    }
</script>

<style>
</style>
