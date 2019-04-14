export default class {
    id
    created
    updated
    name
    description
    status
    manager
    totalImplementationCost
    totalFunding
    balance
    debtorCount
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
        protocol.totalFunding = arr[8].toNumber()
        protocol.balance = arr[9].toNumber()
        protocol.debtorCount = arr[10].toNumber()
        protocol.remainingDebt = arr[11].toNumber()
        return protocol
    }

    fundingProgress() {
        return (this.balance / this.totalImplementationCost)
    }

    static stateNumToString(num) {
        let str =  {
            0: 'Draft',
            1: 'TeamFormation',
            2: 'Funding',
            3: 'Implementation',
            4: 'Production',
            5: 'Commonized',
        }[num]
        if (!str) throw "Not found: " + num
        return str
    }

    static stateNumFromString(str) {
        let num = {
            'Draft': 0,
            'TeamFormation': 1,
            'Funding': 2,
            'Implementation': 3,
            'Production': 4,
            'Commonized': 5,
        }[str]
        if (!num) throw "Not found: " + str
        return num
    }
}