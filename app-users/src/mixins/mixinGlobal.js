export default {
    
    created() {
    },

    methods: {
        showError(msg, exc) {
            if (exc) {
                console.error(msg + ":", exc)
                alert(msg + ": " +  exc)
            } else  {
                console.error(msg)
                alert(msg)
            }
        },

        safePromiseCall(callback) {
            return new Promise((resolve, reject) => {
                try {
                    callback(resolve, reject)
                } catch(e) {
                    reject(e)
                }
            })
        },
    }
}