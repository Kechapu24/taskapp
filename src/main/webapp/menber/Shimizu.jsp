<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>マイページ</title>

<style>
    /* 画面全体のベース設定 */
    body {
        font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
        color: #333333;
        background-color: #f8f9fa;
        padding: 30px;
        margin: 0;
    }

    /* マイページのタイトル部分 */
    .profile-header h2 {
        color: #222222;
        margin-bottom: 8px;
    }

    /* 緑色の現在ステータス */
    .status-badge {
        background-color: #e2f0d9;
        color: #385723;
        padding: 6px 12px;
        border-radius: 20px;
        display: inline-block;
        font-weight: bold;
        font-size: 14px;
        margin: 0;
    }

    /* 区切り線 */
    hr {
        border: 0;
        border-top: 1px solid #e0e0e0;
        margin: 25px 0;
    }

    /* 4つの箱を2×2で綺麗に並べる設定 */
    .dashboard-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    /* 4つの箱の共通デザイン */
    .card {
        background: #ffffff;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        border-top: 5px solid #007bff;
        display: flex;
        flex-direction: column; /* メモ欄のボタン配置用 */
    }

    .card h3 {
        color: #007bff;
        margin-top: 0;
        margin-bottom: 15px;
    }

    ul {
        padding-left: 20px;
        line-height: 1.8;
    }

    li {
        margin-bottom: 8px;
    }

    /* 進捗バーの背景（薄いグレー部分 ＋ 濃い枠線を追加） */
    .progress-container {
        width: 100%;
        background-color: #e9ecef;
        border: 1px solid #888888; /* ここで枠線を濃くしました */
        border-radius: 10px;
        margin-top: 5px;
        overflow: hidden;
    }

    /* 進捗バーの青い部分（現在30%） */
    .progress-bar {
        width: 30%;
        background-color: #007bff;
        color: white;
        text-align: center;
        font-size: 12px;
        font-weight: bold;
        padding: 4px 0;
    }

    /* 新しく追加したメモ用テキストエリア */
    .memo-textarea {
        width: 100%;
        height: 100px;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
        resize: none; /* サイズを固定 */
        font-family: inherit;
        box-sizing: border-box; /* はみ出し防止 */
        margin-bottom: 15px; /* ボタンとの間に余白 */
    }

    /* 戻るボタンのデザイン */
    .back-btn {
        margin-top: auto;
        align-self: flex-start;
        background-color: #6c757d;
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 5px;
        cursor: pointer;
        font-size: 14px;
        transition: 0.2s;
    }

    .back-btn:hover {
        background-color: #5a6268;
    }

</style>

</head>
<body>

    <div class="profile-header">
        <h2>👤shimizuのマイページ</h2>
        <p class="status-badge">🟢 現在：EclipseでJSPの練習中！</p>
    </div>

    <hr>

    <div class="dashboard-grid">
        
        <div class="card">
            <h3>📈 現在の進捗</h3>
            <ul>
                <li><strong>外枠：</strong> B班全員で作成中！</li>
                <li><strong>現在の全体進捗：</strong>
                    <div class="progress-container">
                        <div class="progress-bar">30%</div>
                    </div>
                </li>
            </ul>
        </div>

        <div class="card">
            <h3>🛠️ 今していること</h3>
            <p>ページのレイアウト作成</p>
        </div>

        <div class="card">
            <h3>🎯 今週の目標</h3>
            <ul>
                <li><input type="checkbox"> 自分で選んだタスクを終わらせる</li>
                <li><input type="checkbox"> ページ作りをしながら理解を深める</li>
            </ul>
        </div>

        <div class="card">
            <h3>📝 メモ</h3>
            <textarea class="memo-textarea" placeholder="ここにアイデアや気付きをメモできます..."></textarea>
            
            <button class="back-btn" onclick="history.back()">◀ 前のページに戻る</button>
        </div>

    </div>

</body>
</html>