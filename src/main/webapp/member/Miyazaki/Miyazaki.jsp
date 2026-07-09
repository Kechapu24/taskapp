<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>宮﨑 実可 | 個人ページ</title>

<link rel="stylesheet" href="m.style.css">
</head>

<body>
<header>
    <h1>宮﨑 実可</h1>
    <p>システム開発演習 個人ページ</p>
</header>

</body>

<nav>
    #profile自己紹介</a>
    #teamチーム紹介</a>
    #role担当内容</a>
    #contribution
    #learning
</nav>

<div class="container">

    <section id="profile">
        <h2>自己紹介</h2>

        <p>
            Java・JSP・Linux・Git・Tomcat・PostgreSQLを学習しています。
            システム開発演習では、チームでタスク管理アプリケーションの開発に取り組んでいます。
        </p>
    </section>

    <section id="team">
        <h2>私たちのチーム</h2>

        <p>
            私たちのチームは、細かな設計を最初に全て決めるのではなく、
            まず動くものを作りながら改善していくアジャイル型の開発を意識して進めています。
        </p>

        <p>
            メンバー同士で相談しながら機能追加や修正を行い、
            実際に動作確認を繰り返しながら開発しています。
        </p>
    </section>

    <section id="role">
        <h2>担当内容</h2>

        <ul>
            <li>Eclipseプロジェクト作成</li>
            <li>ログイン画面の作成</li>
            <li>ID入力欄の実装</li>
            <li>パスワード入力欄の実装</li>
            <li>名前入力欄の実装</li>
            <li>新規登録ポップアップ画面の作成</li>
            <li>画面レイアウト調整</li>
        </ul>
    </section>

    <section id="contribution">
        <h2>チームへの貢献</h2>

        <ul>
            <li>開発開始のための環境準備</li>
            <li>ログイン機能の画面作成</li>
            <li>新規登録画面のUI実装</li>
            <li>GitHubによる共同開発への参加</li>
            <li>不具合の原因調査と修正対応</li>
        </ul>
    </section>

    <section>
        <h2>苦労したこと</h2>

        <h3>個人ページのリンクエラー</h3>

        <p>
            開発メンバー一覧から個人ページへ遷移できない問題が発生しました。
        </p>

        <ul>
            <li>GitHub上では修正済み</li>
            <li>学校サーバーのtaskappは古い状態</li>
            <li>Tomcatへの反映も未実施</li>
        </ul>

        <p>
            ログ調査やgrepコマンドを利用して原因を特定し、
            git pull と再デプロイによって解決しました。
        </p>
    </section>

    <section id="learning">
        <h2>学んだこと</h2>

        <div class="card">
            <h3>Git</h3>
            <p>
                pushだけではサーバーは更新されず、
                pullによる最新ソース取得が必要であることを学びました。
            </p>
        </div>

        <div class="card">
            <h3>Tomcat</h3>
            <p>
                webapps/ROOTへ配置し直してデプロイする流れを理解しました。
            </p>
        </div>

        <div class="card">
            <h3>ApacheとTomcat</h3>
            <p>
                Apacheがリクエストを受け取り、
                Tomcatへ転送してJSPを実行していることを理解しました。
            </p>
        </div>

        <div class="card">
            <h3>調査力</h3>
            <p>
                URL・grep・Git・Tomcatの状態を確認しながら、
                問題を切り分ける方法を学びました。
            </p>
        </div>
    </section>

    <section>
        <h2>制作物</h2>

        <p>
            チームでタスク管理アプリを開発しています。
        </p>

        <ul>
            <li>ログイン機能</li>
            <li>ユーザー登録機能</li>
            <li>タスク管理機能</li>
            <li>JSPによる画面作成</li>
        </ul>
    </section>

    <section>
        <h2>今後の目標</h2>

        <ul>
            <li>Javaの理解を深める</li>
            <li>データベース設計を学ぶ</li>
            <li>セキュリティの知識を身につける</li>
            <li>チーム開発経験を積む</li>
        </ul>
    </section>

</div>

<footer>
    <p>© 2026 宮﨑 実可</p>
</footer>

</body>
</html>
