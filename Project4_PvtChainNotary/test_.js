addLevelDBData([2,1], "value1")

 readAllOrWriteToLevelDB(null, null, true).then((result)=>{console.log(result)})


 getLevelDBData([2,1]).then((res)=>{console.log(res)})

