import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { gameId: Number };

  connect() {
    // Helpful debug so you can confirm Stimulus attached this controller
    try {
      console.log(
        "[new-round] connected",
        this.element,
        "gameId=",
        this.gameIdValue
      );
    } catch (e) {
      console.log("[new-round] connected (no gameId)", this.element);
    }
  }

  async startNewRound(event) {
    event.preventDefault();
    const url = `/games/${this.gameIdValue}/new_round`;
    const token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");
    try {
      const resp = await fetch(url, {
        method: "POST",
        headers: { "X-CSRF-Token": token, Accept: "text/html" },
      });
      if (!resp.ok) throw new Error("Network response not ok");
      const html = await resp.text();
      const container = document.getElementById("game-container");
      if (container) container.innerHTML = html;
    } catch (err) {
      console.error("New round failed", err);
      window.location.reload();
    }
  }
}
