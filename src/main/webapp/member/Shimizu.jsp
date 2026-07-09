<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>マイページ - タスク管理ダッシュボード</title>
<style>
    :root {
        --primary-color: #4361ee;
        --secondary-color: #3f37c9;
        --success-color: #4cc9f0;
        --bg-color: #f8f9fa;
        --card-bg: #ffffff;
        --text-main: #2b2d42;
        --text-muted: #8d99ae;
        --border-color: #edf2f4;
        --memo-bg: #f8f9fa;
    }

    body {
        font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
        background-color: var(--bg-color);
        color: var(--text-main);
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        overflow-x: hidden;
    }

    /* 水風船モード中だけ全体のカーソルを変え、要素のクリックや選択を完全に無効化する */
    body.balloon-mode-active {
        cursor: crosshair;
        user-select: none;
    }
    body.balloon-mode-active .dashboard-container * {
        pointer-events: none;
    }

    .dashboard-container { max-width: 1200px; width: 100%; padding: 30px; box-sizing: border-box; position: relative; z-index: 1; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .page-title { font-size: 28px; font-weight: bold; margin: 0; color: var(--text-main); }
    .date-display { background: var(--card-bg); padding: 8px 16px; border-radius: 20px; font-size: 14px; font-weight: bold; color: var(--primary-color); box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
    
    /* 基本レイアウト：左350px（サイドバー）、右は残り全部（メイン） */
    .layout-grid { display: grid; grid-template-columns: 350px 1fr; gap: 30px; }
    
    /* カードの基本設定 */
    .card { 
        background: var(--card-bg); 
        border-radius: 16px; 
        padding: 25px; 
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03); 
        border: 1px solid var(--border-color); 
        margin-bottom: 30px; 
        transition: transform 0.2s ease, box-shadow 0.2s ease; 
        position: relative; 
        overflow: hidden;
    }
    /* カラムの最後のカードの余白を調整 */
    .left-column .card:last-child, .right-column .card:last-child { margin-bottom: 0; }
    .card:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(0, 0, 0, 0.06); }
    
    /* カニの下敷きにならないようテキストを上に設定 */
    .card-title, .profile-section, .mission-list, .report-container, .progress-info, .progress-bg, #memoPad, .btn-container {
        position: relative;
        z-index: 2;
        background: transparent;
        pointer-events: none; 
    }
    
    /* 例外: メモ帳とボタンは通常モードでクリックが効くようにする */
    #memoPad, .btn-container { pointer-events: auto; }

    .card-title { font-size: 18px; font-weight: bold; margin: 0 0 20px 0; border-bottom: 2px solid var(--border-color); padding-bottom: 12px; color: var(--text-main); }
    .profile-section { text-align: center; padding-bottom: 20px; }
    .avatar { width: 100px; height: 100px; background: linear-gradient(135deg, var(--primary-color), var(--success-color)); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 40px; color: white; margin: 0 auto 15px auto; box-shadow: 0 4px 15px rgba(67, 97, 238, 0.3); }
    .user-name { font-size: 22px; font-weight: bold; margin: 0 0 5px 0; color: var(--text-main); }
    .user-role { color: var(--text-muted); font-size: 14px; margin: 0 0 15px 0; }
    .status-badge { background-color: rgba(76, 201, 240, 0.2); color: var(--primary-color); padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: bold; display: inline-block; }

    .mission-list { list-style: none; padding: 0; margin: 0; }
    .mission-list li { position: relative; padding-left: 25px; margin-bottom: 15px; line-height: 1.5; font-size: 15px; color: var(--text-main); }
    .mission-list li::before { content: "■"; position: absolute; left: 0; top: 0; color: var(--primary-color); font-size: 12px; }

    .report-container { background: rgba(248, 249, 250, 0.85); border-left: 4px solid var(--primary-color); padding: 20px; border-radius: 0 8px 8px 0; }
    .report-item { margin-bottom: 10px; font-size: 15px; line-height: 1.6; color: var(--text-main); }
    .report-highlight { color: var(--primary-color); font-weight: bold; }

    .progress-info { display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 8px; font-weight: bold; color: var(--text-main); }
    .progress-bg { width: 100%; background-color: var(--border-color); border-radius: 10px; height: 12px; overflow: hidden; }
    .progress-fill { height: 100%; background: linear-gradient(90deg, var(--primary-color), var(--success-color)); width: 0%; transition: width 1s cubic-bezier(0.4, 0, 0.2, 1); border-radius: 10px; }

    .memo-textarea { width: 100%; height: 320px; padding: 15px; border: 1px solid var(--border-color); border-radius: 10px; resize: none; font-family: inherit; font-size: 14px; box-sizing: border-box; margin-bottom: 15px; background-color: rgba(248, 249, 250, 0.85); color: var(--text-main); }
    .memo-textarea:focus { outline: none; border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.2); }
    
    .btn-container { display: flex; gap: 15px; justify-content: flex-end; }
    .btn { padding: 10px 24px; border-radius: 8px; border: none; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; }
    .btn-back { background-color: var(--border-color); color: var(--text-main); }
    .btn-save { background-color: var(--primary-color); color: white; }

    @media (max-width: 900px) { 
        .layout-grid { grid-template-columns: 1fr; }
    }

    /* カニのアニメーション */
    .hidden-creature {
        position: absolute;
        z-index: 1;
        display: inline-block;
        cursor: pointer;
        font-size: 18px;
        user-select: none;
        opacity: 0.65;
        pointer-events: auto !important;
        animation: crabDeepWalk 60s linear infinite;
    }
    .hidden-creature:hover { animation-play-state: paused; transform: scale(1.3); opacity: 1; }

    @keyframes crabDeepWalk {
        0%   { left: 5%;   top: 15px;  transform: scaleX(1); }   
        15%  { left: 85%;  top: 45px;  transform: scaleX(1); }   
        16%  { transform: scaleX(-1); }                          
        35%  { left: 5%;   top: 85px;  transform: scaleX(-1); }  
        36%  { transform: scaleX(1); }                           
        55%  { left: 85%;  top: 130px; transform: scaleX(1); }   
        56%  { transform: scaleX(-1); }                          
        75%  { left: 5%;   top: 180px; transform: scaleX(-1); }  
        76%  { transform: scaleX(1); }                           
        95%  { left: 85%;  top: 220px; transform: scaleX(1); }   
        100% { left: 5%;   top: 15px;  transform: scaleX(1); }   
    }

    /* 水風船とペイントのCSS */
    #paintCanvas { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 998; pointer-events: none; }
    .water-balloon {
        position: fixed;
        width: 40px; height: 44px;
        background: radial-gradient(circle at 35% 35%, #4cc9f0 0%, #4361ee 70%, #3f37c9 100%);
        border-radius: 50% 50% 50% 50% / 40% 40% 60% 60%;
        box-shadow: inset -4px -4px 8px rgba(0,0,0,0.2), 0 8px 15px rgba(0,0,0,0.15);
        z-index: 1011; pointer-events: none;
        transform: translate(-50%, -50%) scale(2.5);
        transition: all 0.4s cubic-bezier(0.25, 1, 0.5, 1);
    }

    .clear-btn {
        position: fixed; bottom: 40px; right: 40px; width: 60px; height: 60px; border-radius: 50%;
        background-color: #ff4d6d; box-shadow: 0 4px 15px rgba(0,0,0,0.2); display: none;
        align-items: center; justify-content: center; font-size: 24px; cursor: pointer;
        z-index: 1000; border: 3px solid white; user-select: none; pointer-events: auto !important;
        animation: popUp 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .clear-btn:hover { transform: scale(1.1); }
    @keyframes popUp { from { transform: scale(0); } to { transform: scale(1); } }
</style>
</head>
<body>

    <canvas id="paintCanvas"></canvas>

    <div class="dashboard-container">
        <header class="page-header">
            <h1 class="page-title">マイページ</h1>
            <div class="date-display" id="todayDate">202X年XX月XX日</div>
        </header>

        <div class="layout-grid">
            
            <div class="left-column">
                <div class="card">
                    <div class="profile-section">
                        <div class="avatar">👤</div>
                        <h2 class="user-name">shimizu</h2>
                        <p class="user-role">B班 開発メンバー</p>
                        <div class="status-badge">🟢 開発作業中</div>
                    </div>
                </div>

                <div class="card" id="slot1">
                    <h3 class="card-title">🎯 自身の担当</h3>
                    <ul class="mission-list">
                        <li><strong>フロントエンド・UI設計</strong><br>
                            <span style="color: var(--text-muted); font-size: 13px;">ホームページを完成像に近づけるためのレイアウト構築・CSSスタイリング</span>
                        </li>
                        <li><strong>マイページ画面の実装</strong><br>
                            <span style="color: var(--text-muted); font-size: 13px;">レスポンシブ対応を取り入れたダッシュボードデザインの制作</span>
                        </li>
                    </ul>
                </div>

                <div class="card" id="slot3">
                    <h3 class="card-title">📈 プロジェクト進捗状況</h3>
                    <div style="margin-bottom: 20px;">
                        <div class="progress-info">
                            <span>UI作成 (自身の担当)</span><span>70%</span>
                        </div>
                        <div class="progress-bg"><div class="progress-fill" style="width: 0%;" data-target="70"></div></div>
                    </div>
                    <div>
                        <div class="progress-info">
                            <span>B班 全体の開発進行度</span><span>30%</span>
                        </div>
                        <div class="progress-bg"><div class="progress-fill" style="width: 0%;" data-target="30"></div></div>
                    </div>
                </div>

                <div class="card" id="slot5">
                    <h3 class="card-title">📅 次回予定</h3>
                    <ul class="mission-list">
                        <li><strong>ホームページの機能を拡充</strong><br>
                            <span style="color: var(--text-muted); font-size: 13px;">データベースからのプロジェクト・タスク情報の動的表示機能を追加する</span>
                        </li>
                        <li><strong>UI/UXの改善</strong><br>
                            <span style="color: var(--text-muted); font-size: 13px;">細かな所を修正・改善</span>
                        </li>
                        <li><strong>連携機能のテスト</strong><br>
                            <span style="color: var(--text-muted); font-size: 13px;">プロジェクト一覧画面との連携</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="right-column">
                <div class="card" style="border-top: 4px solid var(--primary-color);" id="slot2">
                    <h3 class="card-title">📝 当日の作業報告</h3>
                    <div class="report-container">
                        <div class="report-item">・Gitのプッシュ・プルによるリポジトリ同期の解決</div>
                        <div class="report-item">・データベース接続用パス修正と疎通確認</div>
                        <div class="report-item">・マイページのUIレイアウト作成とJS機能の追加</div>
                        <div style="margin-top: 15px; font-size: 14px;">
                            <span class="report-highlight">【現在の状況】</span><br>
                            マイページのコーディングが完了。
                        </div>
                    </div>
                </div>

                <div class="card" id="slot4">
                    <h3 class="card-title">📋 ワークスペース・メモ</h3>
                    <textarea id="memoPad" class="memo-textarea" placeholder="アイデアや気づきをメモ...（自動でブラウザに保存されます）"></textarea>
                    <div class="btn-container">
                        <button class="btn btn-back" onclick="history.back()">◀ 戻る</button>
                        <button class="btn btn-save" onclick="alert('ブラウザに自動保存されました！')">保存</button>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <div class="clear-btn" id="clearBtn" title="お片付けして通常に戻る">🧹</div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // --- 1. 日付表示とプログレスバー ---
            const now = new Date();
            document.getElementById("todayDate").innerText = "📅 " + now.getFullYear() + "年" + (now.getMonth() + 1) + "月" + now.getDate() + "日";

            setTimeout(() => {
                document.querySelectorAll('.progress-fill').forEach(bar => {
                    bar.style.width = bar.getAttribute('data-target') + '%';
                });
            }, 300);

            // --- 2. メモの自動保存 ---
            const memoPad = document.getElementById("memoPad");
            const savedMemo = localStorage.getItem("myDashboardMemo");
            if (savedMemo) {
                memoPad.value = savedMemo;
            }
            memoPad.addEventListener("input", function() {
                localStorage.setItem("myDashboardMemo", this.value);
            });

            // --- 3. 水風船モード ---
            let isBalloonMode = false;
            const canvas = document.getElementById("paintCanvas");
            const ctx = canvas.getContext("2d");
            const clearBtn = document.getElementById("clearBtn");

            let currentMouseX = 0;
            let currentMouseY = 0;
            let throwInterval = null;
            let holdTimeout = null;

            function hideCreature() {
                const slots = ["slot1", "slot2", "slot3", "slot4", "slot5"];
                const randomSlotId = slots[Math.floor(Math.random() * slots.length)];
                const targetCard = document.getElementById(randomSlotId);

                const creatureEl = document.createElement("span");
                creatureEl.className = "hidden-creature";
                creatureEl.innerText = "🦀";
                creatureEl.title = "みつかった！クリック！";

                targetCard.appendChild(creatureEl);

                creatureEl.addEventListener("click", function(e) {
                    e.stopPropagation();
                    if (!isBalloonMode) {
                        isBalloonMode = true;
                        document.body.classList.add("balloon-mode-active");
                        clearBtn.style.display = "flex";
                        alert("画面をクリック!");
                        creatureEl.remove();
                    }
                });
            }
            hideCreature();

            function resizeCanvas() {
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;
            }
            window.addEventListener("resize", resizeCanvas);
            resizeCanvas();

            function throwBalloon(x, y) {
                const balloon = document.createElement("div");
                balloon.classList.add("water-balloon");
                balloon.style.left = (window.innerWidth / 2) + "px";
                balloon.style.top = (window.innerHeight + 50) + "px";
                document.body.appendChild(balloon);

                requestAnimationFrame(() => {
                    balloon.style.left = x + "px";
                    balloon.style.top = y + "px";
                    balloon.style.transform = "translate(-50%, -50%) scale(0.6) rotate(30deg)";
                });

                setTimeout(() => {
                    balloon.remove();
                    paintSplash(x, y);
                }, 400);
            }

            window.addEventListener("mousemove", function(e) {
                currentMouseX = e.clientX;
                currentMouseY = e.clientY;
            });

            window.addEventListener("mousedown", function(e) {
                if (!isBalloonMode) return;
                if (e.target.id === "clearBtn" || e.target.closest(".clear-btn")) return;

                currentMouseX = e.clientX;
                currentMouseY = e.clientY;

                throwBalloon(currentMouseX, currentMouseY);

                holdTimeout = setTimeout(() => {
                    throwInterval = setInterval(() => {
                        throwBalloon(currentMouseX, currentMouseY);
                    }, 100);
                }, 500); 
            });

            function stopFiring() {
                clearTimeout(holdTimeout);
                clearInterval(throwInterval);
            }
            window.addEventListener("mouseup", stopFiring);
            window.addEventListener("mouseleave", stopFiring);

            // ▼▼ 修正：色ムラをなくして完全に均一にしたペイント関数 ▼▼
            function paintSplash(x, y) {
                const mainRadius = 75; // 半径約5cm
                ctx.save();
                
                // 【メインの水風船の跡（均一な色）】
                // 1回目は透明度25%の青。4回重なると真っ青（透明度100%相当）になります。
                ctx.beginPath();
                ctx.arc(x, y, mainRadius, 0, Math.PI * 2);
                ctx.fillStyle = "rgba(25, 115, 255, 0.25)"; 
                ctx.fill();

                // 【周りに飛び散る小さな水滴】
                // こちらもメインと同じ透明度25%の均一な色に統一
                const splashCount = 4 + Math.floor(Math.random() * 5);
                for (let i = 0; i < splashCount; i++) {
                    const angle = Math.random() * Math.PI * 2;
                    const distance = mainRadius + (Math.random() * 40);
                    const splashX = x + Math.cos(angle) * distance;
                    const splashY = y + Math.sin(angle) * distance;
                    const radius = 3 + (Math.random() * 7);

                    ctx.beginPath();
                    ctx.arc(splashX, splashY, radius, 0, Math.PI * 2);
                    ctx.fillStyle = "rgba(25, 115, 255, 0.25)";
                    ctx.fill();
                }
                ctx.restore();
            }
            // ▲▲ ここまで ▲▲

            clearBtn.addEventListener("click", function() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                stopFiring();
                
                isBalloonMode = false;
                document.body.classList.remove("balloon-mode-active");
                clearBtn.style.display = "none";
                
                const oldCreature = document.querySelector(".hidden-creature");
                if (oldCreature) oldCreature.remove();
                hideCreature();
            });
        });
    </script>
</body>
</html>