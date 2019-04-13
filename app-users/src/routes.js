import Vue from 'vue'
import Router from 'vue-router'
import Account from '@/views/Account'
import List from '@/views/List'
import Register from '@/views/Register'

Vue.use(Router)

export default new Router({
    routes: [
        {
            path: '/',
            name: 'Home',
            component: List
        },
        {
            path: '/account',
            name: 'Account',
            component: Account
        },
        {
            path: '/register',
            name: 'Register',
            component: Register
        },
    ],
    linkActiveClass: 'active'
})
