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
        background: var(--chat-bg);
        display: flex;
        flex-direction: column;
        height: 100vh;
    }

    /* ヘッダー */
    .header {
        padding: 12px 25px;
        border-bottom: 1px solid var(--border-color);
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .header-logo {
        font-size: 22px;
        background: linear-gradient(135deg, #4285f4, #ea4335, #fbbc05, #34a853);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: bold;
    }
    .header-title { font-size: 15px; font-weight: bold; color: var(--text-muted); }

    /* チャットエリア */
    .chat-area {
        flex-grow: 1;
        padding: 15px 30px;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        gap: 15px;
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
        width: 34px;
        height: 34px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        flex-shrink: 0;
    }
    .user .avatar { background-color: var(--primary-color); color: white; }
    .bot .avatar { background: linear-gradient(135deg, #e3f2fd, #bbdefb); }

    .message-body {
        display: flex;
        flex-direction: column;
        width: 100%;
    }
    .user .message-body { align-items: flex-end; }

    /* 吹き出しデザイン */
    .message-content {
        padding: 12px 18px;
        border-radius: 16px;
        font-size: 15px;
        line-height: 1.5;
    }
    .user .message-content {
        background-color: var(--user-bubble);
        border-bottom-right-radius: 4px;
        white-space: pre-wrap; 
    }
    .bot .message-content {
        background-color: var(--bot-bubble);
        border: 1px solid var(--border-color);
        border-bottom-left-radius: 4px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.02);
        width: 100%;
        white-space: normal; 
    }

    /* アクションボタン（コピー・いいね・バッド） */
    .message-actions {
        display: flex;
        gap: 6px;
        margin-top: 4px; 
        margin-left: 4px;
    }
    .action-btn {
        background: transparent;
        border: none;
        font-size: 15px;
        cursor: pointer;
        padding: 6px;
        border-radius: 6px;
        /* ★修正：透明度を下げ、少し色味を残してくっきり表示させる */
        filter: grayscale(70%) opacity(0.85);
        transition: 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .action-btn:hover {
        background: #f0f4f9;
        /* ホバー時はフルカラー＆不透明に */
        filter: grayscale(0%) opacity(1);
    }
    .action-btn.active {
        filter: grayscale(0%) opacity(1);
        transform: scale(1.15);
    }
    .like-btn.active { background: #e3f2fd; }
    .dislike-btn.active { background: #fce8e6; }

    /* ボット回答内のレイアウト */
    .res-title {
        font-size: 15px;
        font-weight: bold;
        color: var(--primary-color);
        margin-bottom: 6px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .res-list { margin: 0; padding-left: 20px; color: var(--text-main); }
    .res-list li { margin-bottom: 4px; }
    .task-item { margin-bottom: 8px; }
    .task-title { font-weight: bold; color: var(--text-main); }
    .task-desc { font-size: 13px; color: var(--text-muted); margin-top: 1px; }

    .status-badge {
        display: inline-block;
        background: #e3f2fd;
        color: var(--primary-color);
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: bold;
        margin-right: 8px;
    }

    /* 進捗バー */
    .progress-block { margin-bottom: 12px; width: 100%; }
    .progress-info { display: flex; justify-content: space-between; font-size: 13px; font-weight: bold; margin-bottom: 6px; }
    .progress-track { width: 100%; height: 2px; background-color: #dcdcdc; position: relative; cursor: ew-resize; }
    .progress-fill { height: 4px; background: linear-gradient(90deg, var(--primary-color), #4cc9f0); position: absolute; top: -1px; left: 0; border-radius: 2px; pointer-events: none; }
    .progress-fill::after { content: ''; position: absolute; right: -8px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px; background: #ffffff; border: 3px solid var(--primary-color); border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.2); }
    .progress-fill.completed { background: linear-gradient(90deg, #f9ca24, #f0932b); }
    .progress-fill.completed::after { border-color: #f9ca24; }

    /* 入力エリア */
    .input-container { padding: 15px 30px; background: var(--chat-bg); border-top: 1px solid var(--border-color); }
    .suggestions { display: flex; gap: 10px; margin-bottom: 10px; overflow-x: auto; }
    .chip { background: var(--bg-color); border: 1px solid var(--border-color); padding: 6px 14px; border-radius: 20px; font-size: 13px; cursor: pointer; white-space: nowrap; transition: 0.2s; }
    .chip:hover { background: #e0e0e0; }

    .input-box { background: var(--bg-color); border-radius: 30px; padding: 8px 15px 8px 20px; display: flex; align-items: center; gap: 15px; transition: 0.3s; }
    .input-box:focus-within { background: white; border-color: var(--primary-color); box-shadow: 0 0 0 2px rgba(11, 87, 208, 0.2); }
    .chat-input { flex-grow: 1; border: none; background: transparent; font-size: 15px; color: var(--text-main); outline: none; height: 24px; }
    .send-btn { background: var(--user-bubble); border: none; width: 38px; height: 38px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; font-size: 16px; }
    .send-btn.active { background: var(--primary-color); color: white; }

    /* コピーしましたのトースト通知 */
    .toast {
        position: fixed;
        bottom: 90px;
        left: 50%;
        transform: translateX(-50%);
        background-color: rgba(30, 30, 30, 0.85);
        color: white;
        padding: 10px 20px;
        border-radius: 25px;
        font-size: 14px;
        font-weight: bold;
        z-index: 1000;
        pointer-events: none;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        animation: fadeToast 2s ease forwards;
    }

    @keyframes fadeToast {
        0% { opacity: 0; transform: translate(-50%, 15px); }
        15% { opacity: 1; transform: translate(-50%, 0); }
        85% { opacity: 1; transform: translate(-50%, 0); }
        100% { opacity: 0; transform: translate(-50%, -15px); }
    }

    @keyframes slideUpFade {
        from { opacity: 0; transform: translateY(15px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .typing-indicator { display: flex; gap: 4px; padding: 4px 0; }
    .dot { width: 7px; height: 7px; background-color: #a0a0a0; border-radius: 50%; animation: typing 1.4s infinite ease-in-out both; }
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

    <div class="chat-area" id="chatArea">
        <div class="message-wrapper bot">
            <div class="avatar">✨</div>
            <div class="message-body">
                <div class="message-content">こんにちは！B班 開発メンバー shimizuのパーソナルAIアシスタントです。<br>プロジェクトの状況や予定について、何でも聞いてください。</div>
            </div>
        </div>
    </div>

    <div class="input-container">
        <div class="suggestions">
            <div class="chip" onclick="sendKeyword('今日の報告')">📝 今日の報告</div>
            <div class="chip" onclick="sendKeyword('次回報告')">📅 次回報告</div>
            <div class="chip" onclick="sendKeyword('進捗どう？')">📈 進捗どう？</div>
            <div class="chip" onclick="sendKeyword('担当タスク')">🎯 担当タスク</div>
        </div>

        <div class="input-box">
            <input type="text" id="chatInput" class="chat-input" placeholder="メッセージを入力（例：次回報告は？）" onkeypress="handleKeyPress(event)">
            <button class="send-btn" id="sendBtn" onclick="handleSend()">➤</button>
        </div>
    </div>
</div>

<script>
    const chatInput = document.getElementById('chatInput');
    const sendBtn = document.getElementById('sendBtn');
    const chatArea = document.getElementById('chatArea');

    chatInput.addEventListener('input', () => {
        if (chatInput.value.trim().length > 0) {
            sendBtn.classList.add('active');
        } else {
            sendBtn.classList.remove('active');
        }
    });

    function handleKeyPress(e) {
        if (e.key === 'Enter') handleSend();
    }

    function sendKeyword(text) {
        chatInput.value = text;
        handleSend();
    }

    function handleSend() {
        const text = chatInput.value.trim();
        if (text === '') return;

        appendMessage('user', text);
        chatInput.value = '';
        sendBtn.classList.remove('active');

        const typingId = showTypingIndicator();

        let thinkTime = 800 + Math.random() * 800;
        if (Math.random() < 0.2) { 
            thinkTime = 2500 + Math.random() * 1500; 
        }

        setTimeout(() => {
            removeTypingIndicator(typingId);
            const response = generateResponse(text);
            const messageWrapper = appendMessage('bot', response, true);
            initProgressBars(messageWrapper);
        }, thinkTime);
    }

    function appendMessage(sender, text, isHtml = false) {
        const wrapper = document.createElement('div');
        wrapper.className = `message-wrapper ${sender}`;
        
        const avatar = document.createElement('div');
        avatar.className = 'avatar';
        avatar.innerText = sender === 'user' ? '👤' : '✨';
        
        const body = document.createElement('div');
        body.className = 'message-body';

        const content = document.createElement('div');
        content.className = 'message-content';
        if (isHtml) content.innerHTML = text;
        else content.innerText = text;

        body.appendChild(content);

        // ユーザーからの質問に対するボットの返答の時のみボタンを生成
        if (sender === 'bot') {
            const actions = document.createElement('div');
            actions.className = 'message-actions';
            actions.innerHTML = `
                <button class="action-btn copy-btn" title="コピー" onclick="copyMessage(this)">📋</button>
                <button class="action-btn like-btn" title="いいね" onclick="toggleReaction(this, 'like')">👍</button>
                <button class="action-btn dislike-btn" title="よくないね" onclick="toggleReaction(this, 'dislike')">👎</button>
            `;
            body.appendChild(actions);
        }

        wrapper.appendChild(avatar);
        wrapper.appendChild(body);
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
            <div class="message-body">
                <div class="message-content">
                    <div class="typing-indicator">
                        <div class="dot"></div><div class="dot"></div><div class="dot"></div>
                    </div>
                </div>
            </div>
        `;
        chatArea.appendChild(wrapper);
        chatArea.scrollTop = chatArea.scrollHeight;
        return id;
    }

    function removeTypingIndicator(id) {
        const el = document.getElementById(id);
        if (el) el.remove();
    }

    function copyMessage(btn) {
        const contentBox = btn.closest('.message-body').querySelector('.message-content');
        const textToCopy = contentBox.innerText;

        navigator.clipboard.writeText(textToCopy).then(() => {
            showToast('✓ コピーしました！');
        }).catch(err => {
            showToast('コピーに失敗しました');
        });
    }

    function showToast(message) {
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.innerText = message;
        document.body.appendChild(toast);

        setTimeout(() => {
            if (document.body.contains(toast)) {
                toast.remove();
            }
        }, 2000);
    }

    function toggleReaction(btn, type) {
        const container = btn.closest('.message-actions');
        const likeBtn = container.querySelector('.like-btn');
        const dislikeBtn = container.querySelector('.dislike-btn');
        
        if (type === 'like') {
            btn.classList.toggle('active');
            dislikeBtn.classList.remove('active'); 
        } else {
            btn.classList.toggle('active');
            likeBtn.classList.remove('active'); 
        }
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

            track.addEventListener('mousedown', (e) => {
                isDragging = true;
                handleMove(e);
            });

            const handleMove = (e) => {
                if(!isDragging) return;
                const rect = track.getBoundingClientRect();
                let x = e.clientX - rect.left;
                let pct = (x / rect.width) * 100;
                updateUI(pct);
                localStorage.setItem(key, pct); 
            };

            const handleUp = () => {
                isDragging = false;
            };

            document.addEventListener('mousemove', handleMove);
            document.addEventListener('mouseup', handleUp);
        });
    }

    function generateResponse(input) {
        const text = input.toLowerCase();

        if (text.includes('次回') && text.includes('報告')) {
            return `
                <div class="res-title">📅 次回報告の予定タスク</div>
                <div class="task-item">
                    <div class="task-title">ホームページの機能を拡充</div>
                    <div class="task-desc">データベースからの動的表示機能を追加</div>
                </div>
                <div class="task-item">
                    <div class="task-title">UI/UXの改善</div>
                    <div class="task-desc">細かな所の修正・改善</div>
                </div>
                <div class="task-item">
                    <div class="task-title">連携機能のテスト</div>
                    <div class="task-desc">プロジェクト一覧画面との連携</div>
                </div>`;
        }
        else if (text.includes('今日') || text.includes('今回') || (text.includes('報告') && !text.includes('次回'))) {
            return `
                <div class="res-title">📝 当日の作業報告</div>
                <ul class="res-list">
                    <li>Gitのプッシュ・プルによる同期解決</li>
                    <li>DB接続パス修正と疎通確認</li>
                    <li>マイページのUIレイアウトとJS追加</li>
                </ul>
                <div style="margin-top: 10px; font-size:14px;">
                    <span class="status-badge">現在の状況</span>
                    <span>マイページのコーディングが完了しました。</span>
                </div>`;
        } 
        else if (text.includes('進捗') || text.includes('状況') || text.includes('パーセント')) {
            return `
                <div class="res-title">📈 プロジェクト進捗状況</div>
                <p style="font-size: 12px; color: var(--text-muted); margin: 0 0 10px 0;">※丸いツマミをドラッグして進捗を更新できます。</p>
                <div class="progress-block" data-key="progress_ui">
                    <div class="progress-info">
                        <span>UI作成 (自身の担当)</span>
                        <span class="progress-text" style="color:var(--primary-color);">70%</span>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" data-target="70"></div>
                    </div>
                </div>
                <div class="progress-block" data-key="progress_team">
                    <div class="progress-info">
                        <span>B班 全体の開発進行度</span>
                        <span class="progress-text" style="color:#9b51e0;">30%</span>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" style="background: linear-gradient(90deg, #9b51e0, #d383ff);" data-target="30"></div>
                    </div>
                </div>`;
        }
        else if (text.includes('タスク') || text.includes('担当')) {
            return `
                <div class="res-title">🎯 自身の担当</div>
                <div class="task-item">
                    <div class="task-title">フロントエンド・UI設計</div>
                    <div class="task-desc">ホームページを完成像に近づけるためのレイアウト構築</div>
                </div>
                <div class="task-item">
                    <div class="task-title">マイページ画面の実装</div>
                    <div class="task-desc">レスポンシブ対応を取り入れたダッシュボードデザインの制作</div>
                </div>`;
        }
        else if (text.includes('お疲れ') || text.includes('ありがとう')) {
            return "お疲れ様です！引き続きB班の開発、頑張っていきましょう！☕️";
        }
        else if (text.includes('名前') || text.includes('誰')) {
            return "私はshimizuさんのダッシュボードAIです。あなたの作業記録やタスク管理をサポートします。";
        }
        else {
            return "すみません、うまく認識できませんでした。<br>「今日の報告」「次回報告」「進捗」「担当タスク」などについて聞いてみてください！";
        }
    }
</script>
</body>
</html>