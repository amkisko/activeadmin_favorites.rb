import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["jsonField", "templates", "hint"]

  connect() {
    this.sync(this.advancedChecked())
  }

  toggle(event) {
    this.sync(event.target.checked)
  }

  sync(advanced) {
    if (this.hasJsonFieldTarget) {
      this.jsonFieldTarget.hidden = !advanced
      this.jsonFieldTarget.disabled = !advanced
    }
    if (this.hasHintTarget) {
      this.hintTarget.hidden = !advanced
    }
    if (this.hasTemplatesTarget) {
      this.templatesTarget.querySelectorAll("input, select").forEach((element) => {
        if (element.type === "hidden") return
        element.disabled = advanced
      })
    }
  }

  advancedChecked() {
    const checkbox = this.element.querySelector("#favorite_use_advanced_macros")
    return Boolean(checkbox?.checked)
  }
}
