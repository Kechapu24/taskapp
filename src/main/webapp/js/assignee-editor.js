
(function() {

	function getEditor(element) {
		return element.closest(".assignee-editor");
	}

	function getSelectedIds(editor) {
		return new Set(
			Array.from(
				editor.querySelectorAll(".assignee-editor-chip")
			).map(chip => chip.dataset.userId)
		);
	}

	function updateOptions(editor) {
		const input = editor.querySelector(".assignee-editor-search");
		const keyword = input.value.trim().toLowerCase();
		const selectedIds = getSelectedIds(editor);

		let visibleCount = 0;

		editor.querySelectorAll(".assignee-editor-option")
			.forEach(option => {

				const userId = option.dataset.userId;
				const name = option.querySelector(
					".assignee-editor-name"
				).textContent.trim().toLowerCase();

				const visible =
					!selectedIds.has(userId) &&
					name.includes(keyword);

				option.hidden = !visible;

				if (visible) {
					visibleCount++;
				}
			});

		editor.querySelector(".assignee-editor-empty").hidden =
			visibleCount > 0;
	}

	function setMenuOpen(editor, open) {
		editor.querySelector(".assignee-editor-menu")
			.classList.toggle("open", open);

		editor.querySelector(".assignee-editor-toggle")
			.setAttribute("aria-expanded", String(open));

		if (open) {
			updateOptions(editor);
		}
	}

	function addAssignee(editor, option) {
		const userId = option.dataset.userId;

		if (getSelectedIds(editor).has(userId)) {
			return;
		}

		const chip = document.createElement("span");
		chip.className = "assignee-editor-chip";
		chip.dataset.userId = userId;

		const avatar = option.querySelector(
			".assignee-editor-avatar"
		).cloneNode(true);

		chip.appendChild(avatar);

		const name = document.createElement("span");
		name.textContent = option.querySelector(
			".assignee-editor-name"
		).textContent.trim();

		chip.appendChild(name);

		const hidden = document.createElement("input");
		hidden.type = "hidden";
		hidden.name = "user_ids";
		hidden.value = userId;

		chip.appendChild(hidden);

		const remove = document.createElement("button");
		remove.type = "button";
		remove.className = "assignee-editor-remove";
		remove.textContent = "×";
		remove.setAttribute("aria-label", "担当者を解除");

		chip.appendChild(remove);

		editor.querySelector(".assignee-editor-selected")
			.appendChild(chip);

		editor.querySelector(".assignee-editor-search").value = "";

		// 次の担当者を続けて追加できるよう、候補は開いたままにする
		setMenuOpen(editor, true);
	}

	document.addEventListener("focusin", function(event) {
		if (event.target.matches(".assignee-editor-search")) {
			setMenuOpen(getEditor(event.target), true);
		}
	});

	document.addEventListener("input", function(event) {
		if (event.target.matches(".assignee-editor-search")) {
			setMenuOpen(getEditor(event.target), true);
		}
	});

	document.addEventListener("click", function(event) {

		const option = event.target.closest(".assignee-editor-option");

		if (option) {
			addAssignee(getEditor(option), option);
			return;
		}

		const remove = event.target.closest(".assignee-editor-remove");

		if (remove) {
			const editor = getEditor(remove);
			remove.closest(".assignee-editor-chip").remove();
			updateOptions(editor);
			return;
		}

		const toggle = event.target.closest(".assignee-editor-toggle");

		if (toggle) {
			const editor = getEditor(toggle);
			const menu = editor.querySelector(".assignee-editor-menu");

			setMenuOpen(editor, !menu.classList.contains("open"));
			return;
		}

		if (!event.target.closest(".assignee-editor")) {
			document.querySelectorAll(".assignee-editor")
				.forEach(editor => setMenuOpen(editor, false));
		}
	});

	document.addEventListener("keydown", function(event) {
		if (event.key === "Escape") {
			document.querySelectorAll(".assignee-editor")
				.forEach(editor => setMenuOpen(editor, false));
		}
	});


	// 編集画面で既存の担当者を選択済みにする
	window.selectAssigneeIdsInEditor = function(editor, userIds) {

		if (!editor) {
			return;
		}

		const options = Array.from(
			editor.querySelectorAll(".assignee-editor-option")
		);

		(userIds || []).forEach(function(userId) {

			const option = options.find(function(item) {
				return item.dataset.userId === String(userId);
			});

			if (option) {
				addAssignee(editor, option);
			}
		});

		setMenuOpen(editor, false);
	};

})();
