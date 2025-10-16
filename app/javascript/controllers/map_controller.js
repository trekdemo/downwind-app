import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import { default as lh } from "leaflet-hotline"

lh(L)

// Connects to data-controller="activity--map"
export default class extends Controller {
  static targets = ["map", "loading"]
  static values = {
    gpxUrl: String,
    compareUrls: Array,
    bounds: Object
  }
  connect() {
    this.initializeMap()
    this.loadPrimaryRoute()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initializeMap() {
    // Map initialization with mobile-first responsive design
    this.map = L.map(this.mapTarget, {
      zoomControl: window.innerWidth > 768, // Hide zoom on mobile
      attributionControl: true
    })

    // OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)

    // Set initial view based on cached bounds or default
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
      const gpxData = await this.fetchGPX(this.gpxUrlValue)
      const routeData = this.parseGPX(gpxData)
      this.renderRoute(routeData, { primary: true })

      // Load comparison routes if specified
      if (this.compareUrlsValue.length > 0) {
        await this.loadComparisonRoutes()
      }
    } catch (error) {
      this.showError('Failed to load route data')
      console.error('Route loading error:', error)
    } finally {
      this.hideLoading()
    }
  }

  async fetchGPX(url) {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    return await response.text()
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
        const speedKMH = speedMPS * 3.6

        currentPoint.speed = speedKMH
        minSpeed = Math.min(minSpeed, speedKMH)
        maxSpeed = Math.max(maxSpeed, speedKMH)
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

  renderRoute(routeData, options = {}) {
    const hotlinePoints = routeData.points.map(point => [
      point.lat,
      point.lng,
      point.speed
    ])

    const hotlineConfig = {
      min: routeData.minSpeed,
      max: routeData.maxSpeed,
      palette: {
        0.0: '#1974D2',   // Blue - slow
        0.5: '#FFFF00',   // Yellow - medium
        0.75: '#FF0000',  // Red - fast
        1.0: '#822EFF'    // Purple - very fast
      },
      weight: options.primary ? 4 : 3,
      outlineWidth: 0.5,
      opacity: options.primary ? 1.0 : 0.8
    }

    const hotlineLayer = L.hotline(hotlinePoints, hotlineConfig)
    hotlineLayer.addTo(this.map)

    // Add hover tooltip for pace display
    hotlineLayer.on('mouseover', (e) => {
      const speed = e.latlng.speed || 0
      const pace = this.speedToPace(speed) // Convert to min/km

      L.popup()
        .setLatLng(e.latlng)
        .setContent(`<strong>Pace:</strong> ${pace} min/km`)
        .openOn(this.map)
    })

    // Fit map to route bounds if primary route
    if (options.primary && routeData.bounds) {
      this.map.fitBounds([
        [routeData.bounds.south, routeData.bounds.west],
        [routeData.bounds.north, routeData.bounds.east]
      ])
    }

    return hotlineLayer
  }

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

  speedToPace(speedKMH) {
    if (speedKMH <= 0) return "0:00"

    const minutesPerKM = 60 / speedKMH
    const minutes = Math.floor(minutesPerKM)
    const seconds = Math.floor((minutesPerKM - minutes) * 60)

    return `${minutes}:${seconds.toString().padStart(2, '0')}`
  }

  toRadians(degrees) {
    return degrees * (Math.PI / 180)
  }

  showLoading() {
    this.loadingTarget.classList.remove('hidden')
  }

  hideLoading() {
    this.loadingTarget.classList.add('hidden')
  }

  showError(message) {
    // Could integrate with existing Rails flash message system
    console.error(message)
  }

  // Comparison routes functionality
  async loadComparisonRoutes() {
    for (const compareUrl of this.compareUrlsValue) {
      try {
        const gpxData = await this.fetchGPX(compareUrl)
        const routeData = this.parseGPX(gpxData)
        this.renderRoute(routeData, { primary: false })
      } catch (error) {
        console.warn('Failed to load comparison route:', compareUrl, error)
      }
    }
  }
}
