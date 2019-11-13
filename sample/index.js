const express = require('express')
const app = express()

app.get('/', (req, res) => {
  console.log('Hello world received a request.')

  res.send(`Hello World!`)
})

app.listen(8080, () => {
  console.log('Hello world listening on port 8080')
})