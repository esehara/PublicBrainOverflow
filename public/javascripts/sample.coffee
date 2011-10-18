socket = io.connect()
socket.on "connect",() ->
    console.log "connect"

socket.on "message",(msg) ->
        obj = JSON.parse msg
        objsize = obj.rate + 16
        objcolor = "black"
        if objsize > 64 then objsize = 64
        if objsize > 35 then objclass = "overflow" else objclass = "notoverflow"
        console.log(msg)
        $("#list").prepend("
        <li id='"+obj.post_id+"' class='"+objclass+"'>
        <a class=\"rate\" onclick='plusone(\""+obj.post_id+"\")'>"+obj.rate+"</a>：<span>"+obj.text+"  </span><a style='font-size:8px' onClick='del(\""+obj.post_id+"\")' class='button'>del</a> <a href='#postform' style='font-size:8px' onClick='quote(\"" +obj.post_id+"\")' class='button'>引用</a></li>")
        $("#"+obj.post_id).css("font-size",objsize)
        false

socket.on "disconnect",() ->
        console.log "disconnect"

socket.on "delete",(msg) ->
    console.log msg
    $("#" + msg).css
        "text-decoration":"line-through"

socket.on "plusone",(msg) ->
    $("#" + msg[0]).children(".rate").text(msg[1])
    objsize = msg[1] + 16
    objcolor = "black"
    console.log msg[1]
    if objsize > 64 then objsize = 64
    if objsize > 35 then objclass = "overflow" else objclass = "notoverflow"
    $("#" + msg[0]).css("font-size",objsize)
    document.getElementById(msg[0]).className = objclass
    false

$(window).keydown (e) ->
        if e.keyCode == 13
            message = $ "#text"
            if message.val() != "" then socket.send message.val()
            message.attr "value",""

@plusone = (target_id) ->
    socket.emit "plusone",target_id

@quote = (target_id) ->
    $("#text").attr "value",$("#" + target_id).children("span").text()


@del = (target_id) ->
    socket.emit "delete",target_id
