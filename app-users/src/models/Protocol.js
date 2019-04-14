import _ from 'lodash'

export default class {
    id
    created
    updated
    name
    description
    status
    manager
    totalImplementationCost
    additionalFees

    favored // loaded from LocalStorage


    static fromContractReturn(arr) {
        let protocol = new this()
        protocol.id = arr[0].toNumber()
        protocol.name = arr[1]
        protocol.description = arr[2]
        protocol.created = new Date(arr[3].toNumber())
        protocol.updated = new Date(arr[4].toNumber())
        protocol.manager = arr[5]
        protocol.status = this.stateNumToString(arr[6].toNumber())
        protocol.totalImplementationCost = arr[7].toNumber()
        protocol.additionalFees = arr[8].toNumber()
        return protocol
    }

    static stateNumToString(num) {
        return _.findKey({
            'Draft': 0,
            'TeamFormation': 1,
            'Funding': 2,
            'Implementation': 3,
            'Production': 4,
            'Commonized': 5,
        }, num)
    }
}