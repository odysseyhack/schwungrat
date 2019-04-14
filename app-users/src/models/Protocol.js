export default class {
    id
    created
    updated
    name
    description
    status
    manager
    totalImplementationCost
    balance
    remainingDebt

    favored // loaded from LocalStorage

    static newProtocol() {
        let protocol = new this()
        protocol.totalImplementationCost = 0
        return protocol
    }

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
        protocol.balance = arr[8].toNumber()
        protocol.remainingDebt = arr[9].toNumber()
        return protocol
    }

    fundingProgress() {
        return (this.balance / this.totalImplementationCost)
    }

    static stateNumToString(num) {
        return {
            0: 'Draft',
            1: 'TeamFormation',
            2: 'Funding',
            3: 'Implementation',
            4: 'Production',
            5: 'Commonized',
        }[num]
    }
}