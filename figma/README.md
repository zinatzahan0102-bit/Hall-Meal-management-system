# Figma Export Screens

This folder contains a static HTML/CSS/JS recreation of the Flutter front end with the same green, amber, and soft-white palette.

## Files

- `index.html` - login / authentication screen
- `home.html` - main dashboard
- `meals.html` - meal toggle and history screen
- `routine.html` - activated meal routine list
- `meal-chart.html` - meal count and billing chart screen
- `menu.html` - weekly menu screen
- `activity.html` - reviews and complaint activity screen
- `complaint.html` - complaint submission screen
- `profile.html` - account/profile screen
- `admin.html` - admin dashboard screen
- `admin-home.html` - admin landing screen
- `styles.css` - shared theme tokens and layout system
- `app.js` - shared nav state and small UI helpers

## Run locally

From the repository root, serve the `figma/` directory with any static server.
For example:

```bash
python3 -m http.server 4173 -d figma
```

Then open:

- `http://127.0.0.1:4173/index.html`
- `http://127.0.0.1:4173/home.html`
- `http://127.0.0.1:4173/meals.html`
- `http://127.0.0.1:4173/routine.html`
- `http://127.0.0.1:4173/meal-chart.html`
- `http://127.0.0.1:4173/menu.html`
- `http://127.0.0.1:4173/activity.html`
- `http://127.0.0.1:4173/complaint.html`
- `http://127.0.0.1:4173/profile.html`
- `http://127.0.0.1:4173/admin.html`
- `http://127.0.0.1:4173/admin-home.html`

Use the html.to.design plugin or the Figma browser extension on any screen you want to import.
