# Downwind Journal

A training log for downwind hydrofoiling. Upload a GPX file from your watch
(built with Garmin exports in mind) and the app works out the stats that
matter on a foil: how long and how far you were up, how many times you had to
get back up, and how fast you went.

Live at [downwind.gergo.dev](https://downwind.gergo.dev).

## What it calculates

Every upload is analysed in a background job. The results are stored per
activity:

| Stat                        | What it means                                                          |
| --------------------------- | ---------------------------------------------------------------------- |
| Duration                    | Time between the first and the last trackpoint                         |
| Distance (total)            | Sum of the distances between consecutive trackpoints                   |
| Time / distance on foil     | Absolute and as a percentage of the whole session                      |
| Starts                      | How many times you got up on the foil                                  |
| Speed (avg / max)           | Over the whole session                                                 |
| Speed (avg on foil)         | Only counting the time spent on foil                                   |
| Fastest 1 km                | Quickest time to cover 1000 m anywhere in the track                    |
| Heart rate (avg / max)      | Read from Garmin's `TrackPointExtension`, if the file has it           |
| Route bounds                | Bounding box of the track, used to frame the map                       |

The activity page shows the route on a Mapbox map and on-foil vs. off-foil
charts for both time and distance.

### How "on foil" is detected

GPS tracks don't know when the board is out of the water, so the app infers it
from speed:

1. Distance between consecutive trackpoints is calculated with the haversine
   formula (via `geocoder`), and speed from distance over elapsed time.
2. The speed is smoothed with a rolling mean over roughly the last 20 seconds.
3. You're on foil whenever the smoothed speed is above the activity's **lift
   speed** (km/h, 15 by default, set per activity).
4. Every switch from off foil to on foil counts as a start.

Lift speed depends on the rider, the gear and the discipline, so it can be
edited after upload. Changing it re-runs the analysis.

Activities are tagged with a kind: Downwind SUP, Flatwater Paddle-up,
Dockstart or Wingfoil.

The analysis lives in
[`app/models/foil_activity_analyzer.rb`](app/models/foil_activity_analyzer.rb).
It uses [Daru](https://github.com/SciRuby/daru) data frames. There's a Jupyter
notebook for experimenting with the model in [`docs/jupyter`](docs/jupyter)
(`docker compose up` in that directory).

## Stack

- Ruby 4.0.7 (see `mise.toml` / `.ruby-version`), Rails 8.1
- SQLite for everything: data, plus Solid Queue, Solid Cache and Solid Cable
  in production
- Active Storage on local disk for the uploaded GPX files
- Hotwire (Turbo + Stimulus), importmap, Tailwind CSS, Propshaft
- Clearance for authentication
- Mapbox for interactive and static maps

## Getting started

Prerequisites: Ruby 4.0.7 (`mise install`), SQLite and a
[Mapbox access token](https://account.mapbox.com/access-tokens/).

```sh
echo "MAPBOX_ACCESS_TOKEN=pk.your-token" > .env
bin/setup
```

Run `bin/setup --skip-server` to only set things up, and `bin/dev` to start the
server later.

`bin/rails db:seed` creates a development user (see `db/seeds.rb`). The user
with id `1` is the admin and can manage users under `/admin/users`.

In development, jobs run in-process, so no separate worker is needed.

### Importing a batch of GPX files

To load many files at once in development, put them in `activities/` and run:

```sh
bin/rails import:load
```

This **deletes all activities of the first user** and imports every
`activities/*-DW*.gpx` file as a Downwind SUP activity with a 7 km/h lift
speed.

## Tests and CI

```sh
bin/rspec   # test suite
bin/ci      # everything CI runs: setup, RuboCop, Brakeman, importmap audit, RSpec, seeds
```

GPX fixtures for the specs are in `spec/fixtures`. GitHub Actions
(`.github/workflows/ci.yml`) also runs `bundler-audit`.

## Deployment

The app is deployed with [Kamal](https://kamal-deploy.org) to a single server
(`config/deploy.yml`). Solid Queue runs inside Puma (`SOLID_QUEUE_IN_PUMA`).
SQLite databases and uploaded files live on host volumes.

```sh
bin/deploy   # kamal env push && kamal deploy
```

The deploy needs `RAILS_MASTER_KEY`, `MAPBOX_ACCESS_TOKEN` and
`KAMAL_REGISTRY_PASSWORD` in the environment. `bin/logs-production`,
`bin/ssh-server` and `bin/ssh-container` help with poking at production.
