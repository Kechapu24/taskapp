<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AIチャット風ダッシュボード - shimizu</title>
<style>
    :root {
        --bg-color: #f0f4f9;
        --chat-bg: #ffffff;
        --user-bubble: #e3e3e3;
        --bot-bubble: #ffffff;
        --text-main: #1f1f1f;
        --text-muted: #5f6368;
        --primary-color: #0b57d0;
        --border-color: #e0e0e0;
    }

    body {
        font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', sans-serif;
        background-color: var(--bg-color);
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        height: 100vh;
        color: var(--text-main);
    }

    .app-container {
        width: 100%;
        max-width: 100%;
        background: var(--bg-color);
        display: flex;
        flex-direction: column;
        height: 100vh;
        overflow: hidden;
    }

    /* ヘッダー */
    .header {
        padding: 12px 25px;
        background: var(--chat-bg);
        border-bottom: 1px solid var(--border-color);
        display: flex;
        align-items: center;
        gap: 15px;
        z-index: 10;
    }
    .header-logo {
        font-size: 22px;
        background: linear-gradient(135deg, #4285f4, #ea4335, #fbbc05, #34a853);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: bold;
    }
    .header-title { font-size: 15px; font-weight: bold; color: var(--text-muted); }

    /* ==============================
       ★追加: 初期画面（ウェルカム画面）
       ============================== */
    .initial-view {
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px;
        transition: opacity 0.3s ease;
    }
    .welcome-text {
        text-align: center;
        margin-bottom: 40px;
    }
    .welcome-text h1 {
        font-size: 42px;
        background: linear-gradient(90deg, #4285f4, #d96570);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin: 0 0 10px 0;
    }
    .welcome-text p {
        font-size: 20px;
        color: #444;
        margin: 0;
    }
    .initial-view .input-container {
        width: 100%;
        max-width: 750px;
        background: transparent;
        border: none;
    }
    .initial-view .suggestions { justify-content: center; }
    .initial-view .input-box {
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        padding: 12px 20px 12px 25px;
    }

    /* ==============================
       チャットビュー（送信後に表示）
       ============================== */
    .chat-view-container {
        display: none; /* 初期状態では非表示 */
        flex-direction: column;
        flex-grow: 1;
        background: var(--chat-bg);
        height: 100%;
        overflow: hidden;
    }

    .chat-area {
        flex-grow: 1;
        padding: 15px 30px;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        gap: 20px;
        scroll-behavior: smooth;
    }

    .message-wrapper {
        display: flex;
        gap: 12px;
        max-width: 95%;
        opacity: 0;
        transform: translateY(15px);
        animation: slideUpFade 0.3s ease forwards;
    }
    .message-wrapper.user { align-self: flex-end; flex-direction: row-reverse; }
    .message-wrapper.bot { align-self: flex-start; }

    .avatar {
        width: 34px; height: 34px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px; flex-shrink: 0;
    }
    .user .avatar { background-color: var(--primary-color); color: white; }
    .bot .avatar { background: linear-gradient(135deg, #e3f2fd, #bbdefb); }

    .message-content {
        padding: 12px 18px;
        border-radius: 16px;
        font-size: 15px;
        line-height: 1.6;
        white-space: pre-wrap;
    }
    .user .message-content {
        background-color: var(--user-bubble);
        border-bottom-right-radius: 4px;
    }
    .bot .message-content {
        background-color: var(--bot-bubble);
        border: 1px solid var(--border-color);
        border-bottom-left-radius: 4px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.02);
        width: 100%;
        white-space: normal; 
    }

    /* ==============================
       ★追加: アクションボタン (コピー・評価など)
       ============================== */
    .action-buttons {
        display: flex;
        gap: 8px;
        margin-top: 15px;
        padding-top: 10px;
        border-top: 1px solid #f0f0f0;
        opacity: 0;
        animation: fadeIn 0.5s ease forwards;
    }
    .action-btn {
        background: transparent;
        border: none;
        color: var(--text-muted);
        font-size: 15px;
        cursor: pointer;
        padding: 6px;
        border-radius: 6px;
        transition: 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .action-btn:hover { background: #f0f4f9; color: var(--text-main); }
    .action-btn.active { color: var(--primary-color); background: #e3f2fd; }

    /* ボット回答内のレイアウト */
    .res-title { font-size: 15px; font-weight: bold; color: var(--primary-color); margin-bottom: 6px; display: flex; align-items: center; gap: 8px; }
    .res-list { margin: 0; padding-left: 20px; color: var(--text-main); }
    .res-list li { margin-bottom: 4px; }
    .task-item { margin-bottom: 8px; }
    .task-title { font-weight: bold; color: var(--text-main); }
    .task-desc { font-size: 13px; color: var(--text-muted); margin-top: 1px; }

    /* 進捗バー */
    .progress-block { margin: 10px 0; width: 100%; }
    .progress-info { display: flex; justify-content: space-between; font-size: 13px; font-weight: bold; margin-bottom: 6px; }
    .progress-track { width: 100%; height: 4px; background-color: #dcdcdc; position: relative; cursor: ew-resize; border-radius: 2px;}
    .progress-fill { height: 100%; background: linear-gradient(90deg, var(--primary-color), #4cc9f0); position: absolute; left: 0; border-radius: 2px; pointer-events: none; }
    .progress-fill::after {
        content: ''; position: absolute; right: -8px; top: 50%; transform: translateY(-50%);
        width: 16px; height: 16px; background: #ffffff; border: 3px solid var(--primary-color); border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    .progress-fill.completed { background: linear-gradient(90deg, #f9ca24, #f0932b); }
    .progress-fill.completed::after { border-color: #f9ca24; }

    /* 入力エリア */
    .input-container {
        padding: 15px 30px;
        background: var(--bg-color);
        transition: 0.3s;
    }
    .chat-view-container .input-container {
        background: var(--chat-bg);
        border-top: 1px solid var(--border-color);
    }
    
    .suggestions { display: flex; gap: 10px; margin-bottom: 12px; overflow-x: auto; scrollbar-width: none; }
    .suggestions::-webkit-scrollbar { display: none; }
    .chip { background: var(--chat-bg); border: 1px solid var(--border-color); padding: 8px 16px; border-radius: 20px; font-size: 13px; cursor: pointer; white-space: nowrap; transition: 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.05);}
    .chip:hover { background: #f0f0f0; }
    .chip.disabled { pointer-events: none; opacity: 0.5; } 

    .input-box {
        background: var(--chat-bg);
        border-radius: 30px;
        padding: 8px 15px 8px 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        border: 1px solid var(--border-color);
        transition: 0.3s;
    }
    .input-box:focus-within {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 2px rgba(11, 87, 208, 0.2);
    }
    .input-box.disabled { background: #f5f5f5; pointer-events: none; }
    
    .chat-input { flex-grow: 1; border: none; background: transparent; font-size: 15px; color: var(--text-main); outline: none; height: 26px; }
    .chat-input:disabled { color: #999; }

    .send-btn, .stop-btn {
        border: none; width: 40px; height: 40px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; font-size: 16px;
    }
    .send-btn { background: var(--user-bubble); color: #888;}
    .send-btn.active { background: var(--primary-color); color: white; }
    .stop-btn { background: #1f1f1f; color: white; font-size: 14px; display: none; pointer-events: auto; }
    .stop-btn:hover { background: #ea4335; }

    @keyframes slideUpFade { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

    .typing-indicator { display: flex; gap: 4px; padding: 6px 0; }
    .dot { width: 8px; height: 8px; background-color: #a0a0a0; border-radius: 50%; animation: typing 1.4s infinite ease-in-out both; }
    .dot:nth-child(1) { animation-delay: -0.32s; }
    .dot:nth-child(2) { animation-delay: -0.16s; }
    @keyframes typing { 0%, 80%, 100% { transform: scale(0); } 40% { transform: scale(1); } }
</style>
</head>
<body>

<div class="app-container">
    <div class="header">
        <div class="header-logo">✨ Dashboard AI</div>
        <div class="header-title">shimizu のマイページ</div>
    </div>

    <!-- ★追加：初期画面（中央配置） -->
    <div class="initial-view" id="initialView">
        <div class="welcome-text">
            <h1>こんにちは、shimizuさん</h1>
            <p>プロジェクトの状況や予定について質問してください</p>
        </div>
        <!-- 入力エリアをここに配置（JSで移動させます） -->
        <div id="inputContainerPlaceholder"></div>
    </div>

    <!-- 送信後のチャット画面 -->
    <div class="chat-view-container" id="chatViewContainer">
        <div class="chat-area" id="chatArea">
            <!-- 最初の挨拶 -->
            <div class="message-wrapper bot">
                <div class="avatar">✨</div>
                <div class="message-content">
                    システムが起動しました。何でも聞いてください。
                </div>
            </div>
        </div>
        <div id="chatViewInputPlaceholder"></div>
    </div>

    <!-- 入力コンポーネント（JSで場所を移動します） -->
    <div class="input-container" id="mainInputContainer">
        <div class="suggestions">
            <div class="chip" onclick="sendKeyword('今日の報告')">📝 今日の報告</div>
            <div class="chip" onclick="sendKeyword('次回報告')">📅 次回報告</div>
            <div class="chip" onclick="sendKeyword('進捗どう？')">📈 進捗どう？</div>
            <div class="chip" onclick="sendKeyword('担当タスク')">🎯 担当タスク</div>
        </div>
        <div class="input-box" id="inputBox">
            <input type="text" id="chatInput" class="chat-input" placeholder="メッセージを入力..." onkeypress="handleKeyPress(event)">
            <button class="send-btn" id="sendBtn" onclick="handleSend()">➤</button>
            <button class="stop-btn" id="stopBtn" onclick="handleStop()">■</button>
        </div>
    </div>
</div>

<script>
    // 初期状態では入力エリアを中央（initialView）にセット
    document.getElementById('inputContainerPlaceholder').appendChild(document.getElementById('mainInputContainer'));

    const chatInput = document.getElementById('chatInput');
    const sendBtn = document.getElementById('sendBtn');
    const stopBtn = document.getElementById('stopBtn');
    const inputBox = document.getElementById('inputBox');
    const chatArea = document.getElementById('chatArea');
    const chips = document.querySelectorAll('.chip');

    let aiTimeout = null; 
    let currentTypingId = null; 
    let isTyping = false; // ★追加：文字のカタカタ出力を制御するフラグ
    let typingTimer = null;
    let currentBotContentBox = null; // 現在出力中の吹き出し
    let currentMessageWrapper = null;
    let isFirstMessage = true; // 初回レイアウト変更用

    chatInput.addEventListener('input', () => {
        if (chatInput.value.trim().length > 0) sendBtn.classList.add('active');
        else sendBtn.classList.remove('active');
    });

    function handleKeyPress(e) {
        if (e.key === 'Enter' && !chatInput.disabled) handleSend();
    }

    function sendKeyword(text) {
        if (chatInput.disabled) return; 
        chatInput.value = text;
        handleSend();
    }

    function handleSend() {
        const text = chatInput.value.trim();
        if (text === '') return;

        // ★追加：最初の送信時に、中央レイアウトからチャットレイアウトへ移行する
        if (isFirstMessage) {
            document.getElementById('initialView').style.display = 'none';
            document.getElementById('chatViewContainer').style.display = 'flex';
            document.getElementById('chatViewInputPlaceholder').appendChild(document.getElementById('mainInputContainer'));
            isFirstMessage = false;
        }

        appendMessage('user', text);
        chatInput.value = '';
        sendBtn.classList.remove('active');
        lockInput(true);

        currentTypingId = showTypingIndicator();
        let thinkTime = 1000 + Math.random() * 1000;

        aiTimeout = setTimeout(() => {
            removeTypingIndicator(currentTypingId);
            const response = generateResponse(text);
            
            // ★追加：空の吹き出しを作り、そこに1文字ずつ追加していく
            currentMessageWrapper = appendMessage('bot', '', true);
            currentBotContentBox = currentMessageWrapper.querySelector('.message-content');
            
            // ストリーミング出力開始
            typeHTML(currentBotContentBox, response, () => {
                if (isTyping) { 
                    addActionButtons(currentBotContentBox);
                    initProgressBars(currentMessageWrapper);
                    lockInput(false);
                }
            });
        }, thinkTime);
    }

    // ★追加: 停止ボタンの処理
    function handleStop() {
        isTyping = false; // タイピング出力を強制停止
        if (typingTimer) clearTimeout(typingTimer);
        if (aiTimeout) { clearTimeout(aiTimeout); aiTimeout = null; }
        if (currentTypingId) { removeTypingIndicator(currentTypingId); currentTypingId = null; }
        
        // 途中で止めた場合でもアクションボタンとバーを初期化してあげる
        if (currentBotContentBox) {
            addActionButtons(currentBotContentBox);
            initProgressBars(currentMessageWrapper);
        }
        lockInput(false);
    }

    // ★追加: 文字を1文字ずつカタカタと出力するアニメーション関数
    async function typeHTML(element, htmlString, onComplete) {
        isTyping = true;
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = htmlString;
        element.innerHTML = '';
        
        // HTMLの構造を維持しながら、文字だけを1文字ずつ処理する魔法の関数
        async function processNode(node, parent) {
            if (!isTyping) return;
            
            if (node.nodeType === Node.TEXT_NODE) {
                const text = node.textContent;
                for (let i = 0; i < text.length; i++) {
                    if (!isTyping) return;
                    parent.appendChild(document.createTextNode(text[i]));
                    chatArea.scrollTop = chatArea.scrollHeight;
                    // 文字を打つスピード（10〜30ミリ秒のランダムでリアルさを出す）
                    await new Promise(r => { typingTimer = setTimeout(r, 10 + Math.random() * 20); });
                }
            } else if (node.nodeType === Node.ELEMENT_NODE) {
                const el = document.createElement(node.tagName);
                for (let attr of node.attributes) { el.setAttribute(attr.name, attr.value); }
                parent.appendChild(el);
                for (let child of Array.from(node.childNodes)) {
                    await processNode(child, el);
                }
            }
        }
        
        for (let child of Array.from(tempDiv.childNodes)) {
             await processNode(child, element);
        }
        if (onComplete) onComplete();
    }

    // ★追加: 返信完了後にアクションボタンを追加する関数
    function addActionButtons(container) {
        const actionDiv = document.createElement('div');
        actionDiv.className = 'action-buttons';
        actionDiv.innerHTML = `
            <button class="action-btn" title="コピー" onclick="copyText(this)">📋</button>
            <button class="action-btn" title="Good" onclick="toggleActive(this)">👍</button>
            <button class="action-btn" title="Bad" onclick="toggleActive(this)">👎</button>
            <button class="action-btn" title="再生成" onclick="alert('別の回答を生成します（モックアップ）')">🔄</button>
        `;
        container.appendChild(actionDiv);
        chatArea.scrollTop = chatArea.scrollHeight;
    }

    // コピーボタンの機能
    function copyText(btn) {
        const text = btn.closest('.message-content').innerText;
        navigator.clipboard.writeText(text.replace('📋\n👍\n👎\n🔄', '')); // ボタンの文字を省いてコピー
        const original = btn.innerText;
        btn.innerText = '✔️';
        setTimeout(() => btn.innerText = original, 2000);
    }

    // いいね・バッドボタンの切り替え
    function toggleActive(btn) {
        btn.classList.toggle('active');
    }

    function lockInput(isLocked) {
        chatInput.disabled = isLocked;
        if (isLocked) {
            inputBox.classList.add('disabled');
            sendBtn.style.display = 'none';
            stopBtn.style.display = 'flex';
            chips.forEach(chip => chip.classList.add('disabled'));
        } else {
            inputBox.classList.remove('disabled');
            sendBtn.style.display = 'flex';
            stopBtn.style.display = 'none';
            chips.forEach(chip => chip.classList.remove('disabled'));
            chatInput.focus();
        }
    }

    function appendMessage(sender, text, isHtml = false) {
        const wrapper = document.createElement('div');
        wrapper.className = `message-wrapper ${sender}`;
        const avatar = document.createElement('div');
        avatar.className = 'avatar';
        avatar.innerText = sender === 'user' ? '👤' : '✨';
        const content = document.createElement('div');
        content.className = 'message-content';
        
        if (isHtml) content.innerHTML = text;
        else content.innerText = text;

        wrapper.appendChild(avatar);
        wrapper.appendChild(content);
        chatArea.appendChild(wrapper);
        chatArea.scrollTop = chatArea.scrollHeight;
        return wrapper; 
    }

    function showTypingIndicator() {
        const id = 'typing-' + Date.now();
        const wrapper = document.createElement('div');
        wrapper.className = `message-wrapper bot`;
        wrapper.id = id;
        wrapper.innerHTML = `
            <div class="avatar">✨</div>
            <div class="message-content"><div class="typing-indicator"><div class="dot"></div><div class="dot"></div><div class="dot"></div></div></div>
        `;
        chatArea.appendChild(wrapper);
        chatArea.scrollTop = chatArea.scrollHeight;
        return id;
    }

    function removeTypingIndicator(id) {
        const el = document.getElementById(id);
        if (el) el.remove();
    }

    function initProgressBars(wrapper) {
        const blocks = wrapper.querySelectorAll('.progress-block');
        blocks.forEach(block => {
            const key = block.getAttribute('data-key');
            const track = block.querySelector('.progress-track');
            const fill = block.querySelector('.progress-fill');
            const text = block.querySelector('.progress-text');
            
            let currentVal = localStorage.getItem(key) || fill.getAttribute('data-target');
            updateUI(currentVal);

            let isDragging = false;
            function updateUI(percentage) {
                percentage = Math.max(0, Math.min(100, percentage));
                fill.style.width = percentage + '%';
                text.innerText = Math.round(percentage) + '%';
                if (percentage >= 100) fill.classList.add('completed');
                else fill.classList.remove('completed');
            }

            track.addEventListener('mousedown', (e) => { isDragging = true; handleMove(e); });
            const handleMove = (e) => {
                if(!isDragging) return;
                const rect = track.getBoundingClientRect();
                let x = e.clientX - rect.left;
                let pct = (x / rect.width) * 100;
                updateUI(pct);
                localStorage.setItem(key, pct); 
            };
            const handleUp = () => { isDragging = false; };
            document.addEventListener('mousemove', handleMove);
            document.addEventListener('mouseup', handleUp);
        });
    }

    function generateResponse(input) {
        const text = input.toLowerCase();
        if (text.includes('次回') && text.includes('報告')) {
            return `<div class="res-title">📅 次回報告の予定タスク</div><div class="task-item"><div class="task-title">ホームページの機能を拡充</div><div class="task-desc">データベースからの動的表示機能を追加</div></div><div class="task-item"><div class="task-title">タスク管理アプリのページ作成</div><div class="task-desc">細かな所の修正・改善</div></div><div class="task-item"><div class="task-title">連携機能のテスト</div><div class="task-desc">プロジェクト一覧画面との連携</div></div>`;
        }
        else if (text.includes('今日') || text.includes('今回') || (text.includes('報告') && !text.includes('次回'))) {
            return `<div class="res-title">📝 当日の作業報告</div><ul class="res-list"><li>Gitのプッシュ・プルによる同期解決</li><li>DB接続パス修正と疎通確認</li><li>マイページのUIレイアウトとJS追加</li></ul><div style="margin-top:10px;font-size:14px;"><span style="display:inline-block;background:#e3f2fd;color:var(--primary-color);padding:2px 8px;border-radius:4px;font-size:12px;font-weight:bold;margin-right:8px;">現在の状況</span><span>マイページのコーディングが完了しました。</span></div>`;
        } 
        else if (text.includes('進捗') || text.includes('状況') || text.includes('パーセント')) {
            return `<div class="res-title">📈 プロジェクト進捗状況</div><div class="progress-block" data-key="progress_ui"><div class="progress-info"><span>UI作成 (自身の担当)</span><span class="progress-text" style="color:var(--primary-color);">70%</span></div><div class="progress-track"><div class="progress-fill" data-target="70"></div></div></div><div class="progress-block" data-key="progress_team"><div class="progress-info"><span>B班 全体の開発進行度(目安)</span><span class="progress-text" style="color:#9b51e0;">30%</span></div><div class="progress-track"><div class="progress-fill" style="background:linear-gradient(90deg, #9b51e0, #d383ff);" data-target="30"></div></div></div>`;
        }
        else if (text.includes('タスク') || text.includes('担当')) {
            return `<div class="res-title">🎯 自身の担当ミッション</div><div class="task-item"><div class="task-title">フロントエンド・UI設計</div><div class="task-desc">ホームページを完成像に近づけるためのレイアウト構築</div></div><div class="task-item"><div class="task-title">マイページ画面の実装</div><div class="task-desc">レスポンシブ対応を取り入れたダッシュボードデザインの制作</div></div>`;
        }
        else if (text.includes('お疲れ') || text.includes('疲れた') || text.includes('つかれた')) {
            return "お疲れ様です！🍵 開発は大変だと思いますが、少し休憩も挟みつつ頑張ってくださいね！";
        }
        else {
           const randomReplies = [
                "なるほど、そういうことですね！他にはどんなことが気になりますか？",
                "ふむふむ。その件については、今後チームで相談してみると良いかもしれませんね💡",
                "すみません、まだ学習中の身でして……！代わりに「担当タスク」や「進捗」の確認でもいかがですか？",
                "その言葉、しっかりとメモしておきますね📝 引き続きサポート頑張ります！",
                "申し訳ありません、ちょっと難しいお話でした！良ければメニューのボタンからプロジェクトの状況を確認してみてください✨"
            ];
            return randomReplies[Math.floor(Math.random() * randomReplies.length)];
        }
    }
</script>
</body>
</html>