import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

export default class extends Controller {
  static targets = [ "container" ]

  connect() {
    this.events = []
    this.speed = 0.4 // pixels per frame
    this.x = 0
    this.running = false
    this.loadEvents()
  }

  disconnect() {
    this.stopTicker()
  }

  async loadEvents() {
    try {
      const response = await fetch(`/reputation_events?t=${Date.now()}`)
      if (response.ok) {
        this.events = await response.json()
        if (this.events.length > 0) {
          this.renderTicker()
          this.startTicker()
        } else {
          this.element.style.display = 'none'
        }
      }
    } catch (e) {
      console.error("Failed to load reputation events", e)
      this.element.style.display = 'none'
    }
  }

  renderTicker() {
    const container = this.containerTarget
    container.innerHTML = ""

    const createEventEl = (event) => {
      const el = document.createElement("div")
      el.className = "ticker-item"
      el.style.display = "inline-flex"
      el.style.alignItems = "center"
      el.style.gap = "8px"
      el.style.padding = "4px 16px"
      el.style.fontSize = "13px"
      el.style.whiteSpace = "nowrap"
      
      const isPositive = event.score_delta > 0
      const bg = isPositive ? "rgba(16, 185, 129, 0.06)" : "rgba(239, 68, 68, 0.06)"
      const border = isPositive ? "rgba(16, 185, 129, 0.2)" : "rgba(239, 68, 68, 0.2)"
      const color = isPositive ? "#34D399" : "#F87171"
      
      const deltaText = isPositive ? `+${event.score_delta}` : `${event.score_delta}`
      
      el.innerHTML = `
        <span style="font-weight: 700; color: #FFFFFF;">${escapeHtml(event.entity_name)}</span>
        <span style="color: var(--text-secondary);">${escapeHtml(event.description)}</span>
        <span style="padding: 2px 8px; border-radius: 9999px; border: 1px solid ${border}; background: ${bg}; color: ${color}; font-size: 11px; font-weight: 600;">
          ${deltaText}
        </span>
      `
      return el
    }

    function escapeHtml(unsafe) {
      return (unsafe || "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
    }

    const wrapper = document.createElement("div")
    wrapper.style.display = "flex"
    wrapper.style.alignItems = "center"
    
    this.events.forEach(event => {
      wrapper.appendChild(createEventEl(event))
    })

    const clone = wrapper.cloneNode(true)
    
    container.appendChild(wrapper)
    container.appendChild(clone)
    
    container.style.display = "flex"
    container.style.width = "max-content"
  }

  startTicker() {
    this.running = true
    this.x = 0
    
    const tick = () => {
      if (!this.running) return
      
      const firstChild = this.containerTarget.firstElementChild
      if (firstChild) {
        const width = firstChild.getBoundingClientRect().width
        this.x += this.speed
        if (this.x >= width) {
          this.x = 0
        }
        this.containerTarget.style.transform = `translateX(-${this.x}px)`
      }
      
      requestAnimationFrame(tick)
    }
    
    requestAnimationFrame(tick)
  }

  stopTicker() {
    this.running = false
  }
}
