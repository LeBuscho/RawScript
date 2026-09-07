const GitHub = {
  cfg() {
    return {
      owner: localStorage.getItem("sh_owner") || "",
      repo: localStorage.getItem("sh_repo") || "",
      branch: localStorage.getItem("sh_branch") || "main",
      token: localStorage.getItem("sh_token") || "",
      pagesBase: localStorage.getItem("sh_pages") || ""
    };
  },

  save(cfg) {
    localStorage.setItem("sh_owner", cfg.owner.trim());
    localStorage.setItem("sh_repo", cfg.repo.trim());
    localStorage.setItem("sh_branch", (cfg.branch || "main").trim());
    localStorage.setItem("sh_token", cfg.token.trim());
    localStorage.setItem("sh_pages", cfg.pagesBase.trim());
  },

  configured() {
    const c = this.cfg();
    return c.owner && c.repo && c.token;
  },

  async request(path, options = {}) {
    const c = this.cfg();
    const res = await fetch(`https://api.github.com${path}`, {
      ...options,
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: `Bearer ${c.token}`,
        "X-GitHub-Api-Version": "2022-11-28",
        ...(options.headers || {})
      }
    });
    const text = await res.text();
    let data = null;
    try { data = text ? JSON.parse(text) : null; } catch { data = { raw: text }; }
    if (!res.ok) {
      const msg = data && data.message ? data.message : `HTTP ${res.status}`;
      throw new Error(msg);
    }
    return data;
  },

  pagesUrl(slug) {
    const c = this.cfg();
    const base = c.pagesBase.replace(/\/$/, "");
    if (base) return `${base}/scripts/${slug}.lua`;
    return `https://${c.owner}.github.io/${c.repo}/scripts/${slug}.lua`;
  },

  rawUrl(slug) {
    const c = this.cfg();
    return `https://raw.githubusercontent.com/${c.owner}/${c.repo}/${c.branch}/scripts/${slug}.lua`;
  },

  async listScripts() {
    const c = this.cfg();
    try {
      const data = await this.request(`/repos/${c.owner}/${c.repo}/contents/scripts?ref=${encodeURIComponent(c.branch)}`);
      if (!Array.isArray(data)) return [];
      return data
        .filter(f => f.type === "file" && f.name.endsWith(".lua"))
        .map(f => ({
          name: f.name,
          slug: f.name.replace(/\.lua$/, ""),
          path: f.path,
          sha: f.sha,
          url: f.html_url
        }))
        .sort((a, b) => a.slug.localeCompare(b.slug));
    } catch (err) {
      if (String(err.message).toLowerCase().includes("not found")) return [];
      throw err;
    }
  },

  async getFile(path) {
    const c = this.cfg();
    const data = await this.request(`/repos/${c.owner}/${c.repo}/contents/${path}?ref=${encodeURIComponent(c.branch)}`);
    const content = data.encoding === "base64" ? decodeURIComponent(escape(atob(data.content.replace(/\n/g, "")))) : data.content;
    return { sha: data.sha, content, path: data.path, name: data.name };
  },

  async putFile(path, content, message, sha) {
    const c = this.cfg();
    const body = {
      message,
      content: btoa(unescape(encodeURIComponent(content))),
      branch: c.branch
    };
    if (sha) body.sha = sha;
    return this.request(`/repos/${c.owner}/${c.repo}/contents/${path}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
  },

  async deleteFile(path, sha, message) {
    const c = this.cfg();
    return this.request(`/repos/${c.owner}/${c.repo}/contents/${path}`, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message, sha, branch: c.branch })
    });
  }
};
