express = require 'express'
morgan = require 'morgan'

app = exports.app = express()

app.set 'port', process.env.PORT ? (if 'production' == app.get('env') then 80 else 3001)

app.use morgan('dev')
app.use express.static(__dirname + '/../')

app.listen app.get('port')
console.log "Listening on port #{app.get 'port'}..."
