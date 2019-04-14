// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import 'material-design-icons-iconfont/dist/material-design-icons.css' // needs to be included before vuetify css
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'
import VueLocalStorage from 'vue-localstorage'

import App from './App'
import MixinGlobal from './mixins/mixinGlobal'
import router from './routes'

window.Event = new Vue() // for global events

Vue.use(Vuetify)
Vue.use(VueLocalStorage)
Vue.config.productionTip = false
Vue.mixin(MixinGlobal)

/* eslint-disable no-new */
new Vue({
    el: '#app',
    router,
    components: { App },
    template: '<App/>'
})
