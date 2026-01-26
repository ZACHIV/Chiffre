# Chiffre Web - French Number Trainer

Web version of the Chiffre iOS app. A minimalist, Monet-inspired tool for practicing French number listening comprehension.

## Features

- **Multiple Modes**: Numbers, Phone Numbers, Prices, Time, Year, Month, Trains, Flights.
- **Voice Customization**: Select your preferred French voice and adjust speech rate.
- **Progressive Web App (PWA)**: Installable on mobile and desktop for offline use.
- **Responsive Design**: Beautiful "Monet" interface that adapts to any screen size.
- **Keyboard Shortcuts**:
  - `Space`: Reveal / Next
  - `R`: Replay Audio

## Deployment

### GitHub Pages

This project is configured to deploy automatically to GitHub Pages via GitHub Actions.

1. Go to **Settings** > **Pages** in your GitHub repository.
2. Under **Build and deployment**, select **GitHub Actions** as the source.
3. The workflow file is located at `.github/workflows/deploy.yml`.
4. Push changes to the `main` branch (specifically in the `chiffre-web/` folder) to trigger deployment.

### Local Development

1. Open `index.html` in a modern browser.
2. For PWA features, it's best to serve the folder via a local server (e.g., VS Code Live Server, or `python3 -m http.server`).

## Technologies

- Vanilla HTML/CSS/JavaScript
- CSS Variables for theming
- Web Speech API for TTS
