
(function() {
	"use strict";

	let previousFocus = null;

	function refreshAssignees(form, selectedIds) {

		if (!form) return;

		const mount = form.querySelector(
			".assignee-editor-mount"
		);

		if (!mount) return;

		const projectSelect = form.querySelector(
			'select[name="project_id"]'
		);

		const projectId = projectSelect
			? projectSelect.value
			: mount.dataset.projectId;

		const ids = selectedIds !== undefined
			? selectedIds
			: (mount.dataset.selectedIds || "")
				.split(",")
				.filter(Boolean);

		mount.replaceChildren();

		if (!projectId) {
			mount.textContent =
				"プロジェクトを選択すると担当者を指定できます。";
			return;
		}

		const template = document.getElementById(
			"assignee-project-" + projectId
		);

		if (!template) {
			mount.textContent =
				"担当者候補を取得できません。";

			const submitButton = form.querySelector(
				'button[type="submit"]'
			);

			if (submitButton) {
				submitButton.disabled = true;
			}

			return;
		}

		const submitButton = form.querySelector(
			'button[type="submit"]'
		);

		if (submitButton) {
			submitButton.disabled = false;
		}

		mount.appendChild(
			template.content.cloneNode(true)
		);

		mount.dataset.selectedIds = "";

		const editor = mount.querySelector(
			".assignee-editor"
		);

		if (editor && window.selectAssigneeIdsInEditor) {
			window.selectAssigneeIdsInEditor(
				editor,
				ids
			);
		}
	}

	function open(options) {

		if (!options) return false;

		const mode = options.mode;

		if (!["add", "edit", "detail"].includes(mode)) {
			return false;
		}

		const sourceId = options.sourceId || (
			mode === "add"
				? "task-add-form"
				: mode + "-" + options.taskId
		);

		const source = document.getElementById(sourceId);
		const overlay = document.getElementById(
			"sharedTaskModal"
		);
		const title = document.getElementById(
			"sharedTaskModalTitle"
		);
		const body = document.getElementById(
			"sharedTaskModalBody"
		);

		if (!source || !overlay || !title || !body) {
			console.error(
				"共通タスクモーダルの表示元が見つかりません。",
				sourceId
			);
			return false;
		}

		const titles = {
			add: "タスク追加",
			edit: "タスク編集",
			detail: "タスク詳細"
		};

		previousFocus = document.activeElement;

		title.textContent = titles[mode];

		// 既存の共通JSPから生成済みの内容をコピー
		body.innerHTML = source.innerHTML;

		const form = body.querySelector(
			"form.task-shared-form"
		);

		if (form) {

			if (mode === "add") {
				const statusInput = form.querySelector(
					'input[name="status"]'
				);

				if (statusInput) {
					statusInput.value =
						options.status || "未着手";
				}
			}

			if (options.returnTo) {
				const returnInput = form.querySelector(
					'input[name="return_to"]'
				);

				if (returnInput) {
					returnInput.value = options.returnTo;
				}
			}

			refreshAssignees(
				form,
				mode === "add" ? [] : undefined
			);
		}

		overlay.hidden = false;

		const dialog = overlay.querySelector(
			".task-shared-modal__dialog"
		);

		if (dialog) {
			dialog.focus();
		}

		return true;
	}

	function close() {

		const overlay = document.getElementById(
			"sharedTaskModal"
		);

		if (!overlay) return;

		overlay.hidden = true;

		const body = document.getElementById(
			"sharedTaskModalBody"
		);

		if (body) {
			body.replaceChildren();
		}

		if (previousFocus
			&& document.contains(previousFocus)) {
			previousFocus.focus();
		}

		previousFocus = null;
	}

	document.addEventListener("click", function(event) {

		const overlay = document.getElementById(
			"sharedTaskModal"
		);

		if (!overlay || overlay.hidden) return;

		if (event.target === overlay ||
			event.target.closest("[data-task-modal-close]")) {

			close();
		}
	});

	document.addEventListener("keydown", function(event) {

		if (event.key !== "Escape") return;

		const overlay = document.getElementById(
			"sharedTaskModal"
		);

		if (overlay && !overlay.hidden) {
			close();
		}
	});

	// 他のページからも利用する共通API
	window.TaskModal = {
		open: open,
		close: close,
		refreshAssignees: refreshAssignees
	};

	// 既存taskForm.jspのonchangeとの互換
	window.refreshTaskAssigneeEditor = refreshAssignees;

})();

function getTagEditor(element) {
	return element.closest(".tag-editor");
}

function openTagEditor(input) {

	const editor = getTagEditor(input);

	editor.querySelector(".tag-editor-menu").classList
		.add("open");
}

function toggleTagEditor(button) {

	const editor = getTagEditor(button);

	editor.querySelector(".tag-editor-menu").classList
		.toggle("open");
}

function filterTagEditor(input) {

	const editor = getTagEditor(input);

	const keyword = input.value.trim().toLowerCase();

	const options = editor
		.querySelectorAll(".tag-editor-option");

	options.forEach(function(option) {

		const name = option.textContent.trim().toLowerCase();

		option.style.display = keyword === ""
			|| name.includes(keyword) ? "" : "none";
	});

	editor.querySelector(".tag-editor-menu").classList
		.add("open");
}

function selectExistingTag(button) {

	const editor = getTagEditor(button);

	const tagId = button.dataset.tagId;

	const tagName = button.textContent.trim();

	const color = button.dataset.tagColor;

	const existing = editor
		.querySelector('input[name="tag_ids"][value="'
			+ tagId + '"]');

	if (existing) {
		return;
	}

	createTagChip(editor, tagName, color, "tag_ids", tagId);

	editor.querySelector(".tag-editor-search").value = "";

	editor.querySelector(".tag-editor-menu").classList
		.remove("open");
}

function addNewTag(button) {

	const editor = getTagEditor(button);

	const nameInput = editor.querySelector(".new-tag-name");

	const colorInput = editor.querySelector(".new-tag-color");

	const tagName = nameInput.value.trim();

	const color = colorInput.value;

	if (!tagName) {
		return;
	}

	createNewTagChip(editor, tagName, color);

	nameInput.value = "";
}

function createNewTagChip(editor, tagName, color) {

	const chip = document.createElement("span");

	chip.className = "selected-tag";

	chip.style.backgroundColor = color;

	const text = document.createTextNode(tagName + " ");

	chip.appendChild(text);

	const nameHidden = document.createElement("input");

	nameHidden.type = "hidden";

	nameHidden.name = "new_tag_names";

	nameHidden.value = tagName;

	chip.appendChild(nameHidden);

	const colorHidden = document.createElement("input");

	colorHidden.type = "hidden";

	colorHidden.name = "new_tag_colors";

	colorHidden.value = color;

	chip.appendChild(colorHidden);

	appendRemoveButton(chip);

	editor.querySelector(".selected-tags").appendChild(chip);
}

function createTagChip(editor, tagName, color, inputName, value) {

	const chip = document.createElement("span");

	chip.className = "selected-tag";

	chip.style.backgroundColor = color;

	const text = document.createTextNode(tagName + " ");

	chip.appendChild(text);

	const hidden = document.createElement("input");

	hidden.type = "hidden";

	hidden.name = inputName;

	hidden.value = value;

	chip.appendChild(hidden);

	appendRemoveButton(chip);

	editor.querySelector(".selected-tags").appendChild(chip);
}

function appendRemoveButton(chip) {

	const remove = document.createElement("button");

	remove.type = "button";

	remove.textContent = "×";

	remove.onclick = function() {
		chip.remove();
	};

	chip.appendChild(remove);
}

function removeTagChip(button) {

	button.closest(".selected-tag").remove();
}
