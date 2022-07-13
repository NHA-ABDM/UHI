var stompClient = null;

function setConnected(connected) {
    $("#connect").prop("disabled", connected);
    $("#disconnect").prop("disabled", !connected);
    if (connected) {
        $("#conversation").show();
    }
    else {
        $("#conversation").hide();
    }
    $("#req").html("");
}

const destination = '/user/queue/specific-user';

function connect() {
    var socket = new SockJS('/test');
    stompClient = Stomp.over(socket);
    var messageid = $("#messageId").val()
    stompClient.connect({ name:messageid}, function (frame) {
        setConnected(true);
        console.log('Connected: ' + frame);
        stompClient.subscribe(destination, function (res) {
            console.log(JSON.parse(res.body));
        });
    });
}

function disconnect() {
    if (stompClient !== null) {
        stompClient.disconnect();
    }
    setConnected(false);
    console.log("Disconnected");
}

function sendReqOnSearch() {
    stompClient.send("/on_search",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqOnSelect() {
    stompClient.send("/on_select",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqOnInit() {
    stompClient.send("/on_init",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqOnConfirm() {
    stompClient.send("/on_confirm",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqOnStatus() {
    stompClient.send("/on_status",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqSearch() {
    stompClient.send("/search",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqSelect() {
    stompClient.send("/select",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqInit() {
    stompClient.send("/init",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqConfirm() {
    stompClient.send("/confirm",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqStatus() {
    stompClient.send("/status",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function sendReqGetResponseByMsgId() {
    stompClient.send("/get-response-by-msgId",{}, JSON.stringify(JSON.parse($("#name").val())));
}

function showGreeting(message) {
    $("#greetings").append("<tr><td>" + message + "</td></tr>");
}

$(function () {
    $("form").on('submit', function (e) {
        e.preventDefault();
    });
    $( "#connect" ).click(function() { connect(); });
    $( "#disconnect" ).click(function() { disconnect(); });

    $( "#sendOnSearch" ).click(function() { sendReqOnSearch(); });
    $( "#SendOnSelect" ).click(function() { sendReqOnSelect(); });
    $( "#SendOnInit" ).click(function() { sendReqOnInit(); });
    $( "#SendOnConfirm" ).click(function() { sendReqOnConfirm(); });
    $( "#SendOnStatus" ).click(function() { sendReqOnStatus(); });


    $( "#get-response-by-msgId" ).click(function() { sendReqGetResponseByMsgId(); });

    $( "#sendSearch" ).click(function() { sendReqSearch(); });
    $( "#sendSelect" ).click(function() { sendReqSelect(); });
    $( "#sendInit" ).click(function() { sendReqInit(); });
    $( "#sendConfirm" ).click(function() { sendReqConfirm(); });
    $( "#sendStatus" ).click(function() { sendReqStatus(); });

});