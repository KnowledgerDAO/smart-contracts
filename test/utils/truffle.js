const advanceBlock = (web3) => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: '2.0',
            method: 'evm_mine',
            id: new Date().getTime()
        }, (err, result) => {
            if (err) { return reject(err) }
            return resolve(result)
        })
    })
}

const advanceBlockAfterSomeSeconds = (web3, seconds) => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            method: "evm_increaseTime",
            params: [seconds],
            jsonrpc: "2.0",
            id: new Date().getTime()
          }, (error, result) => {
            if (error) {
                return reject(error);
            }
            return advanceBlock(web3).then( ()=> resolve(result));
          });
    }); 
}

module.exports = {
    advanceBlock,
    advanceBlockAfterSomeSeconds,
}