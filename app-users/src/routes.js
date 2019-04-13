import Vue from 'vue'
import Router from 'vue-router'
import Account from '@/views/Account'
import Register from '@/views/Register'
import ProposalList from '@/views/ProposalList'
import CreateProposal from '@/views/CreateProposal'

Vue.use(Router)

export default new Router({
    routes: [
        {
            path: '/',
            name: 'Home',
            component: ProposalList
        },
        {
            path: '/create',
            name: 'CreateProposal',
            component: CreateProposal
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
