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
                <li><strong>外枠（HTML/CSS）：</strong> 他のメンバーが制作中！</li>
                <li><strong>中身：</strong> すかすか</li>
            </ul>
        </div>

        <div class="card">
            <h3>🛠️ 今していること</h3>
            <p>待ち！</p>
            <p>暇つぶしを兼ねて実験中！</p>
        </div>

        <div class="card">
            <h3>🎯 今週の目標</h3>
            <ul>
                <li><input type="checkbox" checked disabled> 自分のプロフィールの文字を書き換える</li>
                <li><input type="checkbox"> メンバーのHTMLとCSSが完成</li>
            </ul>
        </div>

        <div class="card">
            <h3>📝 予定地（メモ用）</h3>
            <p>ここは後から何かを書き足すための空きスペースです！</p>
            <p>今後のアイデアやメモ、メモ帳での検証用に使ってください。</p>
        </div>

    </div>

</body>
</html>