<template>
  <v-app>
    <TopMenu />

    <v-content>
      <v-container fluid grid-list-lg>
        <v-alert :value="!bcConnected && !bcConnectionError" type="info">
          Connecting to Blockchain...
          <v-btn small flat dark onclick="window.location.reload(false)">Stuck? Click to reload</v-btn>
          <v-progress-linear :indeterminate="true" />
        </v-alert>
        <v-alert :value="bcConnectionError" type="error">
          <h2 class="pb-4">
            Error connecting to the blockchain!
          </h2>

          <p v-if="errorConnectionMessage">
            <b>{{ errorConnectionMessage }}</b>
          </p>

          <p v-show="bcSmartContractAddressError">
            <b>It seems like the address of the smart contract is wrong!</b>
          </p>

          <p>Other common causes of error:</p>
          <ul>
            <li>The blockchain is running.</li>
            <li>The port in your settings (file: <b>mixins/mixinViews.js</b>) match with the blockchain configuration.</li>
            <li>The compiled smart contract(s) <b>app-users/src/assets/contracts/*.json</b> is not up to date with <b>build/*.json</b>.</li>
          </ul>

          <v-btn onclick="window.location.reload(false);">
            Retry
          </v-btn>
        </v-alert>

        <div> <!-- v-show="bcConnected && !bcConnectionError" -->
          <router-view />
        </div>
      </v-container>
    </v-content>
    <v-footer app />
  </v-app>
</template>

<script>
// importing common function
    import mixin from './mixins/mixinViews'
    import TopMenu from './components/TopMenu'

    export default {
        name: 'App',
        components: { TopMenu },
        mixins: [mixin],
    }
</script>

<style>
    h1.title {
        margin-bottom: 50px;
        padding-bottom: 10px;
        border-bottom: 1px solid #CCC;
    }
</style>
