function slugify(title) {
  return title
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/ä/g, "ae")
    .replace(/ö/g, "oe")
    .replace(/ü/g, "ue")
    .replace(/ß/g, "ss")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

const state = {
  scripts: [],
  current: null,
  editor: null
};

function $(id) { return document.getElementById(id); }

function setStatus(msg, kind) {
  const el = $("status");
  el.textContent = msg || "";
  el.className = "status" + (kind ? " " + kind : "");
}

function copyText(text) {
  navigator.clipboard.writeText(text).then(() => setStatus("In die Zwischenablage kopiert.", "ok"));
}

function loadSettingsForm() {
  const c = GitHub.cfg();
  $("cfg-owner").value = c.owner;
  $("cfg-repo").value = c.repo;
  $("cfg-branch").value = c.branch;
  $("cfg-token").value = c.token;
  $("cfg-pages").value = c.pagesBase;
}

function saveSettings() {
  GitHub.save({
    owner: $("cfg-owner").value,
    repo: $("cfg-repo").value,
    branch: $("cfg-branch").value || "main",
    token: $("cfg-token").value,
    pagesBase: $("cfg-pages").value
  });
  $("settings-modal").classList.remove("open");
  setStatus("Einstellungen gespeichert.", "ok");
  refreshList();
}

function showResult(slug) {
  const pages = GitHub.pagesUrl(slug);
  const raw = GitHub.rawUrl(slug);
  const load = `loadstring(game:HttpGet("${raw}"))()`;
  $("url-pages").textContent = pages;
  $("url-raw").textContent = raw;
  $("url-load").textContent = load;
  $("result").classList.add("show");
  $("copy-pages").onclick = () => copyText(pages);
  $("copy-raw").onclick = () => copyText(raw);
  $("copy-load").onclick = () => copyText(load);
}

async function refreshList() {
  const list = $("script-list");
  if (!GitHub.configured()) {
    list.innerHTML = `<div class="empty">Verbinde zuerst dein GitHub-Repository über „Einstellungen“. Danach erscheinen hier alle Dateien aus /scripts.</div>`;
    return;
  }
  list.innerHTML = `<div class="empty">Lade Scripts…</div>`;
  try {
    state.scripts = await GitHub.listScripts();
    if (!state.scripts.length) {
      list.innerHTML = `<div class="empty">Noch keine Scripts im Ordner /scripts. Erstelle oben dein erstes Script.</div>`;
      return;
    }
    list.innerHTML = "";
    state.scripts.forEach(s => {
      const btn = document.createElement("button");
      btn.className = "script-item" + (state.current && state.current.slug === s.slug ? " active" : "");
      btn.innerHTML = `<strong>${s.slug}</strong><span>${s.name}</span>`;
      btn.onclick = () => openScript(s);
      list.appendChild(btn);
    });
  } catch (err) {
    list.innerHTML = `<div class="empty">Konnte Scripts nicht laden: ${err.message}</div>`;
    setStatus(err.message, "err");
  }
}

async function openScript(item) {
  try {
    setStatus("Lade Script…");
    const file = await GitHub.getFile(item.path);
    state.current = { ...item, sha: file.sha };
    $("title").value = item.slug.replace(/-/g, " ");
    state.editor.setValue(file.content || "");
    showResult(item.slug);
    setStatus("Script geladen.", "ok");
    refreshList();
  } catch (err) {
    setStatus(err.message, "err");
  }
}

function newScript() {
  state.current = null;
  $("title").value = "";
  state.editor.setValue("-- Dein Lua-Script\nprint(\"Hello\")\n");
  $("result").classList.remove("show");
  setStatus("Neues Script.");
  refreshList();
}

async function saveScript() {
  if (!GitHub.configured()) {
    setStatus("Bitte zuerst GitHub-Einstellungen ausfüllen.", "err");
    $("settings-modal").classList.add("open");
    return;
  }
  const title = $("title").value.trim();
  const code = state.editor.getValue();
  if (!title) return setStatus("Bitte einen Titel angeben.", "err");
  if (!code.trim()) return setStatus("Bitte Lua-Code einfügen.", "err");

  const slug = slugify(title);
  if (!slug) return setStatus("Titel ergibt keinen gültigen Dateinamen.", "err");

  const path = `scripts/${slug}.lua`;
  $("save-btn").disabled = true;
  setStatus("Speichere auf GitHub…");

  try {
    let sha = state.current && state.current.path === path ? state.current.sha : null;
    if (!sha) {
      const existing = state.scripts.find(s => s.slug === slug);
      if (existing) {
        const file = await GitHub.getFile(existing.path);
        sha = file.sha;
      }
    }
    const msg = sha ? `Update script ${slug}` : `Create script ${slug}`;
    const res = await GitHub.putFile(path, code, msg, sha);
    state.current = {
      slug,
      name: `${slug}.lua`,
      path,
      sha: res.content.sha
    };
    showResult(slug);
    setStatus("Script gespeichert.", "ok");
    await refreshList();
  } catch (err) {
    setStatus(err.message, "err");
  } finally {
    $("save-btn").disabled = false;
  }
}

async function deleteScript() {
  if (!state.current) return setStatus("Kein Script ausgewählt.", "err");
  if (!confirm(`„${state.current.slug}.lua“ wirklich löschen?`)) return;
  try {
    setStatus("Lösche…");
    await GitHub.deleteFile(state.current.path, state.current.sha, `Delete script ${state.current.slug}`);
    newScript();
    await refreshList();
    setStatus("Script gelöscht.", "ok");
  } catch (err) {
    setStatus(err.message, "err");
  }
}

window.addEventListener("DOMContentLoaded", () => {
  state.editor = CodeMirror.fromTextArea($("code"), {
    mode: "lua",
    theme: "material-darker",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    lineWrapping: true,
    matchBrackets: true
  });

  $("save-btn").onclick = saveScript;
  $("new-btn").onclick = newScript;
  $("delete-btn").onclick = deleteScript;
  $("settings-btn").onclick = () => {
    loadSettingsForm();
    $("settings-modal").classList.add("open");
  };
  $("settings-save").onclick = saveSettings;
  $("settings-close").onclick = () => $("settings-modal").classList.remove("open");
  $("refresh-btn").onclick = refreshList;

  $("title").addEventListener("input", () => {
    const slug = slugify($("title").value);
    $("slug-preview").textContent = slug ? `${slug}.lua` : "titel.lua";
  });

  loadSettingsForm();
  if (GitHub.configured()) refreshList();
  else {
    $("script-list").innerHTML = `<div class="empty">Öffne die Einstellungen und verbinde dein GitHub-Repository, damit Scripts gespeichert und als Raw-Dateien ausgeliefert werden können.</div>`;
  }
});
