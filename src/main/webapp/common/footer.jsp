
<%@ page pageEncoding="UTF-8" %>

<footer class="footer">
	<div class="footer-member">
		<a href="#" onclick="toggleMemberMenu()"> 開発メンバー ▼ </a>

		<ul class="member-submenu" id="memberSubmenu">
			<li><a href="member/sakata/Sakata.jsp">坂田</a></li>
			<li><a href="member/Shimizu.jsp">清水</a></li>
			<li><a href="member/Higashi/Higashi.jsp">東</a></li>
			<li><a href="member/Miyazaki/Miyazaki.jsp">宮崎</a></li>
		</ul>
	</div>

	<script>
		function toggleMemberMenu() {
			const menu = document.getElementById("memberSubmenu");

			if (menu.style.display === "block") {
				menu.style.display = "none";
			} else {
				menu.style.display = "block";
			}
		}
	</script>
</footer>