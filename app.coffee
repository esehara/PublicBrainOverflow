# --- Init Request Prug-in
require.paths.push("/usr/local/lib/node_modules")
express = require "express"
mongoose = require "mongoose"
app = express.createServer()
hamljs = require "hamljs"
coffee = require "coffee-script"

# --- Haml Configure
hamljs.filters.coffee = (str) ->
    @javascript coffee.compile(str)

# --- Mongodb Configure
db = process.env.MONGOHQ_URL || "mongodb://localhost/mongo_data"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

BrainPostSchema = new Schema
                text:String
                rate:Number

BrainPostSchema.pre "init",(next) ->
    console.log("initialized")
    next()

BrainPostSchema.pre "save",(next) ->
    console.log("Previous Save")
    if this.isNew then this.rate = 0
    next()

mongoose.model "BrainPost",BrainPostSchema
mongoose.connect db
BrainPost = mongoose.model "BrainPost"

# --- Socket io Configure

io = require("socket.io").listen app

io.configure () ->
    io.set "transports",["xhr-polling"]
    io.set "polling duration",10

io.sockets.on "connection",(socket) ->
    BrainPost.find {},(err,docs) ->
        if !err and docs.length != 0
            doc_number = docs.length
            for i in [0 .. doc_number - 1]
                message = JSON.stringify
                            post_id:docs[i]._id
                            text:docs[i].text
                            rate:docs[i].rate
                console.log(message)
                socket.emit "message",message
    socket.on "message",(msg) ->
        console.log("send :" + msg)
        if msg.length < 140
            msg = escapeHTML(msg)
            post = new BrainPost()
            message = JSON.stringify
                            text:msg
                            rate:0
                            post_id:post._id
            socket.emit "message",message
            socket.broadcast.emit "message",message
            post.text = msg
            post.save (err) ->
                if !err then console.log "save" else console.log "error!!"
            true
    socket.on "disconnect",() ->
            console.log "disconnect"
            true
    socket.on "delete",(msg) ->
            BrainPost.find {_id:msg},(err,docs) ->
                if docs.length > 0
                    BrainPost.remove {_id:docs[0]._id},(err) ->
                    if !err
                        socket.emit "delete",msg
                        socket.broadcast.emit "delete",msg
                    true
    socket.on "plusone",(msg) ->
            BrainPost.find {_id:msg},(err,docs) ->
                if docs.length > 0
                    BrainPost.update {_id:msg},{$set:{rate: docs[0].rate + 1 }}, (err) ->
                        if !err
                            socket.emit "plusone",[msg,docs[0].rate + 1]
                            socket.broadcast.emit "plusone",[msg,docs[0].rate + 1]
        true

escapeHTML  = (str) ->
    str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;")

app.use express.static(__dirname + "/public")
app.register ".haml",require("hamljs")
app.get "/", (req,res) ->
    res.render "index.html.haml"

app.listen process.env.PORT || 3000
