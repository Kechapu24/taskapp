<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>宮﨑 実可</title>
<link rels
</head>
<body>

<header>
    <h1>宮﨑 実可</h1>
    <p>システム開発演習 個人ページ</p>
</header>

<nav>
    #teamチーム紹介</a>
    #role
    tribution">チームへの貢献</a>
    study">学習記録</a>
    ">制作物</a>
</nav>

<div class="container">

    <section>
        <h2>自己紹介</h2>
        <p>
            Java・Linux・Git・Tomcat・PostgreSQLを学習しています。
            システム開発演習ではタスク管理アプリの開発に取り組んでいます。
        </p>
    </section>

    <section id="team">
        <h2>私たちのチーム</h2>

        <p>
            私たちのチームは、最初に細かい仕様をすべて決めるのではなく、
            「まず作ってみる」という考え方で開発を進めています。
        </p>

        <p>
            実際に画面や機能を作成しながら改良を重ねる、
            アジャイル開発に近い形でタスク管理アプリを制作しています。
        </p>
    </section>

    <section id="role">
        <h2>担当内容</h2>

        <ul>
            <li>Eclipseプロジェクトの作成</li>
            <li>開発環境の準備</li>
            <li>ログイン画面の作成</li>
            <li>ID入力欄の実装</li>
            <li>パスワード入力欄の実装</li>
            <li>名前入力欄の実装</li>
            <li>新規登録ポップアップ画面の作成</li>
        </ul>
    </section>

    <section id="contribution">
        <h2>チームへの貢献</h2>

        <ul>
            <li>開発開始に必要なプロジェクト環境を作成</li>
            <li>ログイン画面の実装を担当</li>
            <li>新規登録機能の画面作成を担当</li>
            <li>Gitを利用したソース管理への参加</li>
            <li>動作確認および不具合調査を実施</li>
        </ul>
    </section>

    <section id="study">
        <h2>学習記録</h2>

        <div class="card">
            <h3>Linux</h3>
            <p>サーバー操作やファイル管理について学習。</p>
        </div>

        <div class="card">
            <h3>Git</h3>
            <p>Clone、Pull、Push、Mergeを利用した共同開発を経験。</p>
        </div>

        <div class="card">
            <h3>Tomcat</h3>
            <p>Webアプリケーションのデプロイと公開方法を学習。</p>
        </div>
    </section>

    <section>
        <h2>苦労したこと</h2>

        <ul>
            <li>Tomcatのバージョン違いによるパスの誤り</li>
            <li>git push時の non-fast-forward エラー</li>
            <li>デプロイ後の画面表示エラーの調査</li>
        </ul>

        <p>
            エラーの原因を調査し、Pull・Merge・再デプロイを行い解決しました。
        </p>
    </section>

    <section id="product">
        <h2>制作物</h2>

        <h3>タスク管理アプリ</h3>

        <p>
            グループでタスク管理アプリケーションを開発しています。
        </p>

        <ul>
            <li>ログイン機能</li>
            <li>ユーザー登録機能</li>
            <li>タスク管理機能</li>
            <li>データベース連携</li>
        </ul>
    </section>

    <section>
        <h2>今後の目標</h2>

        <ul>
            <li>Javaの理解を深める</li>
            <li>SQLを活用した開発力向上</li>
            <li>セキュリティ技術の学習</li>
            <li>チーム開発経験を積む</li>
        </ul>
    </section>

</div>

<footer>
    © 2026 宮﨑 実可
</footer>

</body>
</html>