document.addEventListener("DOMContentLoaded", () => {
    let ws;
    let username;

    // Elements
    const usernameScreen = document.getElementById("username-screen");
    const usernameInput = document.getElementById("username-input");
    const log = document.getElementById("log");
    const chatInputRow = document.getElementById("chat-input-row");
    const msgInput = document.getElementById("msg");

    usernameInput.focus();

    function getWebSocketUrl() {
        const protocol =
            window.location.protocol === "https:" ? "wss" : "ws";

        return `${protocol}://${window.location.host}/api/chat/ws`;
    }

    // Start chat after entering username
    function startChat() {
        username = usernameInput.value.trim() || "Anonymous";
        if (!username) return alert("Please enter your name");

        // Hide username screen, show chat
        usernameScreen.style.display = "none";
        log.style.display = "block";
        chatInputRow.style.display = "flex";

        // Open WebSocket
        ws = new WebSocket(getWebSocketUrl());

        ws.onopen = () => {
            // Send username to backend
            ws.send(JSON.stringify({ type: "set_name", name: username }));
        };

        msgInput.focus();

        ws.onmessage = (event) => {
            log.value += event.data + "\n";
            log.scrollTop = log.scrollHeight; // auto-scroll
        };
    };

    document.getElementById("start-chat-btn").addEventListener("click", startChat);


    usernameInput.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            startChat();
        }
    });

    msgInput.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            sendMessage();
        }
    });

    function sendMessage() {
        console.log("sendMessage event received")
        const text = msgInput.value.trim();
        if (text !== "" && ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: "message", text }));
        }
        msgInput.value = "";
    }
});
