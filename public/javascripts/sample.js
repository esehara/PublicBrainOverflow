(function() {
  var socket;
  socket = io.connect();
  socket.on("connect", function() {
    return console.log("connect");
  });
  socket.on("message", function(msg) {
    var obj, objclass, objcolor, objsize;
    obj = JSON.parse(msg);
    objsize = obj.rate + 16;
    objcolor = "black";
    if (objsize > 64) {
      objsize = 64;
    }
    if (objsize > 35) {
      objclass = "overflow";
    } else {
      objclass = "notoverflow";
    }
    console.log(msg);
    $("#list").prepend("        <li id='" + obj.post_id + "' class='" + objclass + "'>        <a class=\"rate\" onclick='plusone(\"" + obj.post_id + "\")'>" + obj.rate + "</a>：<span>" + obj.text + "  </span><a style='font-size:8px' onClick='del(\"" + obj.post_id + "\")' class='button'>del</a> <a href='#postform' style='font-size:8px' onClick='quote(\"" + obj.post_id + "\")' class='button'>引用</a></li>");
    $("#" + obj.post_id).css("font-size", objsize);
    return false;
  });
  socket.on("disconnect", function() {
    return console.log("disconnect");
  });
  socket.on("delete", function(msg) {
    console.log(msg);
    return $("#" + msg).css({
      "text-decoration": "line-through"
    });
  });
  socket.on("plusone", function(msg) {
    var objclass, objcolor, objsize;
    $("#" + msg[0]).children(".rate").text(msg[1]);
    objsize = msg[1] + 16;
    objcolor = "black";
    console.log(msg[1]);
    if (objsize > 64) {
      objsize = 64;
    }
    if (objsize > 35) {
      objclass = "overflow";
    } else {
      objclass = "notoverflow";
    }
    $("#" + msg[0]).css("font-size", objsize);
    document.getElementById(msg[0]).className = objclass;
    return false;
  });
  $(window).keydown(function(e) {
    var message;
    if (e.keyCode === 13) {
      message = $("#text");
      if (message.val() !== "") {
        socket.send(message.val());
      }
      return message.attr("value", "");
    }
  });
  this.plusone = function(target_id) {
    return socket.emit("plusone", target_id);
  };
  this.quote = function(target_id) {
    return $("#text").attr("value", $("#" + target_id).children("span").text());
  };
  this.del = function(target_id) {
    return socket.emit("delete", target_id);
  };
}).call(this);
