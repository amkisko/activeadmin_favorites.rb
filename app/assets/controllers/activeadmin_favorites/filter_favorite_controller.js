import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    createUrl: String,
    path: String,
    queryString: String,
    resourceKey: String,
    actionName: String
  }

  async quickCreate(event) {
    event.preventDefault()

    const body = new FormData()
    body.append("path", this.pathValue)
    body.append("query_string", this.queryStringValue || "")
    body.append("resource_key", this.resourceKeyValue)
    body.append("action_name", this.actionNameValue || "index")
    body.append("authenticity_token", this.csrfToken())

    const response = await fetch(this.createUrlValue, {
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

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
