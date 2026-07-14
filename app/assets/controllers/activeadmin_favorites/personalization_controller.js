import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "catalogGroups", "visibilityCheckbox"]
  static values = {
    resourceKey: String,
    actionName: String,
    path: String,
    catalogElementId: String,
    hidden: Object,
    groupLabels: Object,
    emptyCatalogLabel: String,
    updateUrl: String,
    resetUrl: String,
    saveLensUrl: String,
    favoritesUrl: String
  }

  connect() {
    this.catalogLoaded = false
  }

  prepareMenu() {
    if (!this.catalogLoaded) {
      this.renderCatalogGroups()
      this.catalogLoaded = true
    }

    this.syncCheckboxesFromHidden()
  }

  catalogEntries() {
    const element = document.getElementById(this.catalogElementIdValue)
    if (!element) return []

    try {
      return JSON.parse(element.textContent)
    } catch (_error) {
      return []
    }
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }

  renderCatalogGroups() {
    const grouped = this.catalogEntries().reduce((result, entry) => {
      result[entry.group] ||= []
      result[entry.group].push(entry)
      return result
    }, {})

    const groups = Object.keys(grouped)
    if (groups.length === 0) {
      this.catalogGroupsTarget.innerHTML = `<p class="text-sm text-gray-600 dark:text-gray-300">${this.escapeHtml(this.emptyCatalogLabelValue)}</p>`
      return
    }

    this.catalogGroupsTarget.innerHTML = groups.map((group) => {
      const label = this.escapeHtml(this.groupLabelsValue[group] || group.replace(/_/g, " "))
      const items = grouped[group].map((entry) => {
        const entryLabel = this.escapeHtml(entry.label)
        const entryGroup = this.escapeHtml(entry.group)
        const entryId = this.escapeHtml(entry.id)
        return `
          <li>
            <label class="inline-flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked
                class="rounded border-gray-300 dark:border-white/20"
                data-group="${entryGroup}"
                data-entry-id="${entryId}"
                data-${this.identifier}-target="visibilityCheckbox"
              />
              <span>${entryLabel}</span>
            </label>
          </li>
        `
      }).join("")

      return `
        <div class="mb-4">
          <h4 class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400 mb-2">${label}</h4>
          <ul class="space-y-2 max-h-40 overflow-y-auto">${items}</ul>
        </div>
      `
    }).join("")
  }

  syncCheckboxesFromHidden() {
    const hidden = this.hiddenValue || {}
    this.visibilityCheckboxTargets.forEach((checkbox) => {
      const group = checkbox.dataset.group
      const entryId = checkbox.dataset.entryId
      const hiddenIds = hidden[group] || []
      checkbox.checked = !hiddenIds.includes(entryId)
    })
  }

  currentLayout() {
    const hidden = {}
    this.visibilityCheckboxTargets.forEach((checkbox) => {
      const group = checkbox.dataset.group
      const entryId = checkbox.dataset.entryId
      if (!checkbox.checked) {
        hidden[group] ||= []
        hidden[group].push(entryId)
      }
    })

    return {
      version: 1,
      hidden
    }
  }

  async saveDefault() {
    await this.submitLayout(this.updateUrlValue, "PATCH")
  }

  async resetDefault() {
    const body = new FormData()
    body.append("resource_key", this.resourceKeyValue)
    body.append("view_lens_action", this.actionNameValue)
    body.append("_method", "delete")
    body.append("authenticity_token", this.csrfToken())

    const response = await fetch(this.resetUrlValue, {
      method: "POST",
      body,
      headers: { Accept: "text/html" }
    })

    if (response.redirected) {
      window.location.href = response.url
    } else if (response.ok) {
      window.location.reload()
    }
  }

  async saveLensFavorite() {
    const name = window.prompt(this.promptLabel())
    if (!name) return

    const body = new FormData()
    body.append("name", name)
    body.append("resource_key", this.resourceKeyValue)
    body.append("view_lens_action", this.actionNameValue)
    body.append("path", this.pathValue)
    body.append("layout", JSON.stringify(this.currentLayout()))
    body.append("authenticity_token", this.csrfToken())

    const response = await fetch(this.saveLensUrlValue, {
      method: "POST",
      body,
      headers: { Accept: "text/html" }
    })

    if (response.redirected) {
      window.location.href = response.url
    }
  }

  async submitLayout(url, method) {
    const body = new FormData()
    body.append("resource_key", this.resourceKeyValue)
    body.append("view_lens_action", this.actionNameValue)
    body.append("layout", JSON.stringify(this.currentLayout()))
    body.append("authenticity_token", this.csrfToken())
    if (method !== "POST") body.append("_method", method.toLowerCase())

    const response = await fetch(url, {
      method: method === "PATCH" ? "POST" : method,
      body,
      headers: { Accept: "text/html" }
    })

    if (response.redirected) {
      window.location.href = response.url
    } else if (response.ok) {
      window.location.reload()
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  promptLabel() {
    return this.element.dataset.promptLabel || "Name for lens favorite"
  }
}
