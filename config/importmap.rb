# Pin npm packages by running ./bin/importmap

pin "application", preload: true

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "pwa"
pin_all_from "app/javascript/controllers", under: "controllers"

# Used for the activity map and the colored route lines
pin "leaflet" # @1.9.4
pin "leaflet-hotline" # @0.4.0

# Plugins and additional chart types:  https://github.com/chartjs/awesome
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.4.4/dist/chart.js"
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"
pin "chartjs-plugin-annotation", to: "https://ga.jspm.io/npm:chartjs-plugin-annotation@3.0.1/dist/chartjs-plugin-annotation.esm.js"
pin "chartjs-chart-matrix", to: "https://ga.jspm.io/npm:chartjs-chart-matrix@2.0.1/dist/chartjs-chart-matrix.esm.js"
pin "chart.js/helpers", to: "https://ga.jspm.io/npm:chart.js@4.4.4/helpers/helpers.js"
