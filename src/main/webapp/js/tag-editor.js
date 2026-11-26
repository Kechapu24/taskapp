
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
