import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import { default as hotline } from "leaflet-hotline"

hotline(L) // Register the hotline plugin

// Connects to data-controller="activity--map"
export default class extends Controller {
  static targets = [
    "loading",   // loadingTarget:HTMLElement loader that will be shown/hidden
    "map",       // mapTarget:DivElement containing the leaflet.js map
    "legendMin", // legendMinTarget:HTMLElement optional, filled with min speed (km/h)
    "legendMax", // legendMaxTarget:HTMLElement optional, filled with max speed (km/h)
  ]
  static values = {
    bounds: Object, // boundsValue
    gpxUrl: String, // gpxUrlValue
  }
  connect() {
    this.initializeMap()
    this.loadPrimaryRoute()
  }

  disconnect() {
    if (this.morphFrame) cancelAnimationFrame(this.morphFrame)
    this.map?.remove()
  }

  // Turbo's morph refresh (turbo:morph-element) replaces the map/loading/
  // legend DOM with the server's cold-start markup (empty map div, hidden
  // overlay revealed, legend reset to "–") but leaves this controller
  // connected, so Leaflet is never rebuilt. The event fires once per
  // morphed node and bubbles, so a single refresh can trigger this many
  // times; coalesce into one rebuild per animation frame.
  handleMorph() {
    if (this.morphFrame) return
    this.morphFrame = requestAnimationFrame(() => {
      this.morphFrame = null
      this.reconnect()
    })
  }

  reconnect() {
    // map.remove() clears the container's _leaflet_id, so re-initializing
    // afterwards doesn't hit Leaflet's "already initialized" error.
    this.map?.remove()
    this.initializeMap()
    this.loadPrimaryRoute()
  }

  showLoading() {
    this.loadingTarget.classList.remove('hidden')
  }

  hideLoading() {
    this.loadingTarget.classList.add('hidden')
  }

  initializeMap() {
    // Map initialization with mobile-first responsive design
    // https://leafletjs.com/reference.html#map-factory
    this.map = L.map(this.mapTarget, {
      zoomControl: true,
      attributionControl: true,
    })

    // OpenStreetMap tiles
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)

    // Set initial view based on the route bounds
    if (this.boundsValue && Object.keys(this.boundsValue).length > 0) {
      this.map.fitBounds([
        [this.boundsValue.south, this.boundsValue.west],
        [this.boundsValue.north, this.boundsValue.east]
      ])
    }
  }

  async loadPrimaryRoute() {
    this.showLoading()

    try {
      // TODO: Implement local storage caching to save bandwidth
      // Each file could be around 200-500kb - like a bigger image
      // NOTE: In Safari I saw some issues with Not-modified 304 status.
      // The map just does not render and it an error stating the status code
      // const gpxData = await this.fetchGPX(this.gpxUrlValue, { cache: 'no-store' })
      const gpxData = await this.fetchGPX(this.gpxUrlValue)
      const routeData = this.parseGPX(gpxData)
      this.renderRoute(routeData, { primary: true })
    } catch (error) {
      this.mapTarget.innerText = 'Error loading route: ' + error
      console.error('Route loading error:', error)
    } finally {
      this.hideLoading()
    }
  }

  async fetchGPX(url) {
    const response = await fetch(url)
    if (response.ok) {
      return await response.text()
    } else {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
  }

  parseGPX(xmlString) {
    const parser = new DOMParser()
    const xmlDoc = parser.parseFromString(xmlString, "text/xml")
    const trackPoints = xmlDoc.getElementsByTagName("trkpt")

    if (trackPoints.length < 2) {
      throw new Error("Insufficient trackpoints for route visualization")
    }

    let totalDistance = 0
    let prevPoint = null
    let routePoints = []
    let minSpeed = Infinity
    let maxSpeed = -Infinity

    for (let i = 0; i < trackPoints.length; i++) {
      const point = trackPoints[i]
      const currentPoint = {
        lat: parseFloat(point.getAttribute("lat")),
        lng: parseFloat(point.getAttribute("lon")),
        time: new Date(point.getElementsByTagName("time")[0]?.textContent),
        speed: 0
      }

      if (prevPoint) {
        const distance = this.calculateDistance(prevPoint, currentPoint)
        totalDistance += distance

        const timeDiff = (currentPoint.time - prevPoint.time) / 1000 // seconds
        const speedMPS = timeDiff > 0 ? (distance * 1000) / timeDiff : 0

        currentPoint.speed = speedMPS
        minSpeed = Math.min(minSpeed, speedMPS)
        maxSpeed = Math.max(maxSpeed, speedMPS)
      }

      routePoints.push(currentPoint)
      prevPoint = currentPoint
    }

    return {
      points: routePoints,
      totalDistance,
      minSpeed: minSpeed === Infinity ? 0 : minSpeed,
      maxSpeed: maxSpeed === -Infinity ? 0 : maxSpeed,
    }
  }

  // Calculates distance between two coordinates on Earth in kilometers
  calculateDistance(point1, point2) {
    // Haversine distance formula
    const R = 6371 // Earth's radius in km
    const dLat = this.toRadians(point2.lat - point1.lat)
    const dLng = this.toRadians(point2.lng - point1.lng)

    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(this.toRadians(point1.lat)) *
              Math.cos(this.toRadians(point2.lat)) *
              Math.sin(dLng/2) * Math.sin(dLng/2)

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  }

  toRadians(degrees) {
    return degrees * (Math.PI / 180)
  }

  renderRoute(routeData, options = {}) {
    const hotlinePoints = routeData.points.map(p => [p.lat, p.lng, p.speed])

    const hotlineConfig = {
      min: routeData.minSpeed,
      max: routeData.maxSpeed,
      palette: {
        0.0: '#1974D2',   // Blue - slow
        0.5: '#FFFF00',   // Yellow - medium
        0.75: '#FF0000',  // Red - fast
        1.0: '#822EFF'    // Purple - very fast
      },
      outlineWidth: 0.5,
      weight: options.primary ? 4 : 3,
      opacity: options.primary ? 1.0 : 0.8
    }

    const hotlineLayer = L.hotline(hotlinePoints, hotlineConfig)
    hotlineLayer.addTo(this.map)

    this.updateSpeedLegend(routeData.minSpeed, routeData.maxSpeed)
  }

  // Fills the optional speed legend targets with km/h values (speed is
  // tracked in m/s internally).
  updateSpeedLegend(minSpeedMps, maxSpeedMps) {
    if (this.hasLegendMinTarget) {
      this.legendMinTarget.textContent = this.formatKmh(minSpeedMps)
    }

    if (this.hasLegendMaxTarget) {
      this.legendMaxTarget.textContent = this.formatKmh(maxSpeedMps)
    }
  }

  formatKmh(speedMps) {
    return Math.round(speedMps * 3.6).toString()
  }
}
