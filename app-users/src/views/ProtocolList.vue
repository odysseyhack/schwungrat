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
          <v-card>
            <v-card-title>
              <h4>{{ props.item.name }}</h4>
              <v-spacer />
              <span class="font-weight-bold text-uppercase">{{ props.item.status }}</span>
            </v-card-title>
            <v-divider />

            <v-list dense>
              <v-list-tile>
                <v-list-tile-content>Description:</v-list-tile-content>
                <v-list-tile-content class="align-end">
                  {{ props.item.description }}
                </v-list-tile-content>
              </v-list-tile>
              <v-list-tile>
                <v-list-tile-content>Purpose:</v-list-tile-content>
                <v-list-tile-content class="align-end" />
              </v-list-tile>
            </v-list>

            <v-card-text class="pb-0">
              <strong>Funding:</strong> Wei {{ props.item.balance }} / {{ props.item.totalImplementationCost }}
            </v-card-text>
            <v-progress-linear
              color="info"
              height="10"
              :value="props.item.fundingProgress() * 100"
              class="mb-0"
            />
            <v-divider />

            <v-card-actions>
              <v-btn flat>
                Details
              </v-btn>
              <v-btn flat @click="startFund(props.item)">
                Fund
              </v-btn>
              <v-spacer />
              <v-btn icon>
                <v-icon
                  @click="toggleFavorite(props.item)"
                  v-text="props.item.favored ? 'favorite' : 'favorite_border'"
                />
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-flex>
      </template> <!-- // END PROTOCOL CARD -->

      <template v-slot:no-data>
        <v-alert v-show="!loading" value="true" color="warning">
          No protocols found
        </v-alert>
      </template>
    </v-data-iterator>
  </div>
</template>

<script>
    // importing common function
    import mixin from '../mixins/mixinViews'
    import Protocol from '../models/Protocol'
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

            /** Send fund of given amount to protocol. */
            startFund(protocol) {
                let amount = parseInt(window.prompt("Amount (Wei)", "1"))
                this.safeAsyncContractCall(
                    "Fund protocol " + protocol.id + " with " + amount,
                    (safeCallback) => {
                        window.bc.contract().fundProtocol(protocol.id, {value: amount}, safeCallback) 
                    })
                    .then((data) => {
                        console.log("Fund response:", data)
                        this.reloadList()
                    })
                        
            }
        }
    }
</script>

<style>
</style>
