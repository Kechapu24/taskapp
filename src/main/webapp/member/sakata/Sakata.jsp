<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>自己紹介ホームページ</title>

<link rel="stylesheet" href="css/style.css">

</head>
<body>

<div class="container">

    <!-- ヘッダー -->
    <header class="header">
        <h1>坂田駿右のホームページ</h1>

        <nav>
            <ul class="menu">
                <li><a href="index.jsp">ホーム</a></li>
                <li><a href="profile.jsp">プロフィール</a></li>
                <li><a href="hobby.jsp">趣味</a></li>
                <li><a href="works.jsp">制作物</a></li>
                <li><a href="contact.jsp">お問い合わせ</a></li>
            </ul>
        </nav>
    </header>

    <!-- メイン -->
    <main>

        <!-- 自己紹介 -->
        <section class="hero">

            <h2>こんにちは</h2>

            <p>
                Java・HTML・CSS・JSPを勉強しています。
            </p>

        </section>

        <!-- プロフィール -->
        <section class="card">

            <h2>プロフィール</h2>

            <table>

                <tr>
                    <th>名前</th>
                    <td>坂田　駿右</td>
                </tr>

                <tr>
                    <th>学校</th>
                    <td>湖東カレッジ</td>
                </tr>

                <tr>
                    <th>学科</th>
                    <td>IT経済学科</td>
                </tr>

                <tr>
                    <th>趣味</th>
                    <td>ゲーム</td>
                </tr>

                <tr>
                    <th>目標</th>
                    <td>無事に卒業する</td>
                </tr>

            </table>

        </section>

        <!-- 制作物 -->
        <section class="card">

            <h2>制作物</h2>

            <ul>

                <li>タスク管理アプリ（4人チーム開発）</li>

                <li>Java課題</li>

                <li>個人ホームページ</li>

            </ul>

        </section>

        <!-- スキル -->
        <section class="card">

            <h2>スキル</h2>

            <div class="skill">

                <span>Java</span>

                <span>JSP</span>

                <span>Servlet</span>

                <span>HTML</span>

                <span>CSS</span>

                <span>SQL</span>

            </div>

        </section>

    </main>

    <!-- フッター -->
    <footer>

        <p>
            © 2026 My HomePage
            
        </p>

    </footer>

</div>

</body>
</html>