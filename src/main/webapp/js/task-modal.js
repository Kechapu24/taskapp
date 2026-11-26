
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

			// プロジェクト一覧などから作成する場合
			if (mode === "add" && options.projectId != null) {

				const projectSelect = form.querySelector(
					'select[name="project_id"]'
				);

				if (projectSelect) {
					projectSelect.value = String(options.projectId);
				}
			}

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


	let remoteSourceSequence = 0;

	async function openFromAnyPage(options) {

		if (!options) {
			return false;
		}

		const sourceId = options.sourceId || (
			options.mode === "add"
				? "task-add-form"
				: options.mode + "-" + options.taskId
		);

		// 既存の表示元がある場合はそのまま利用
		if (document.getElementById(sourceId)) {
			return open(options);
		}

		const overlay =
			document.getElementById("sharedTaskModal");

		const endpoint = overlay
			? overlay.dataset.contentUrl
			: null;

		if (!endpoint) {
			console.error("共通モーダルの取得先がありません。");
			return false;
		}

		const params = new URLSearchParams();

		params.set("mode", options.mode);

		if (options.taskId != null) {
			params.set("taskId", options.taskId);
		}

		if (options.returnTo) {
			params.set("returnTo", options.returnTo);
		}

		try {

			const response = await fetch(
				endpoint + "?" + params.toString(),
				{
					credentials: "same-origin",
					cache: "no-store"
				}
			);

			if (!response.ok) {
				throw new Error(
					"モーダル取得エラー: HTTP " + response.status
				);
			}

			const html = await response.text();

			// 取得した共通JSPを一時的な表示元にする
			const source = document.createElement("div");

			source.id =
				"remote-task-source-" + (++remoteSourceSequence);

			source.hidden = true;
			source.innerHTML = html;

			document.body.appendChild(source);

			try {

				const result = open({
					...options,
					sourceId: source.id
				});

				// 詳細JSPの外側にはdisplay:noneがあるので解除
				if (options.mode === "detail" && result) {

					const detail =
						document.querySelector(
							"#sharedTaskModalBody [id^='detail-']"
						);

					if (detail) {
						detail.style.display = "block";
					}
				}

				return result;

			} finally {
				source.remove();
			}

		} catch (error) {

			console.error(error);

			alert(
				"タスク情報を読み込めませんでした。"
			);

			return false;
		}
	}

	// 他のページからも利用する共通API
	window.TaskModal = {
		open: openFromAnyPage,
		close: close,
		refreshAssignees: refreshAssignees
	};

	// 既存taskForm.jspのonchangeとの互換
	window.refreshTaskAssigneeEditor = refreshAssignees;

})();
