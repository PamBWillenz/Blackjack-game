# README

## A Blackjack Game

## Rules - [Blackjack rules](https://bicyclecards.com/how-to-play/blackjack/)

## Prerequisites

- Ruby 3.3.x
- Rails 7.1.x
- Node.js and Yarn (optional, tailwindcss-rails ships a JS binary but yarn/node may be useful)
- PostgreSQL (app expects a database configured in `config/database.yml`)

## Setup (development)

1. Install gems:

```bash
bundle install
```

2. Create and migrate the database:

```bash
bin/rails db:create db:migrate db:seed
```

3. Build or watch Tailwind CSS (the project uses tailwindcss-rails):

One-off build (use before starting production-like server):

```bash
bin/rails tailwindcss:build
```

Watch during development (rebuilds on change):

```bash
bin/rails tailwindcss:watch
```

You can also use `bin/dev` to start the Rails server with background dev processes (if you have a Procfile.dev configured).

## Running the app

Start the Rails server:

```bash
bin/rails server
```

Open http://localhost:3000 and create or visit a game.

## Testing

Run the full test suite (models, controllers, system):

```bash
bin/rails test
```

Run only model tests:

```bash
bin/rails test:models
```

Run only system tests (these use Capybara + headless browser):

```bash
bin/rails test:system
```

## Notes about the game model and tests

- The `Game` model stores a persisted `deck` (Postgres jsonb) and uses helper methods like `deal_initial_cards`, `draw_card!`, and `dealer_play` to manage game flow.
- `Player#hand_value` and `Card#blackjack_value` correctly handle Ace values (counting Ace as 11 then converting to 1 as needed).
- I added and expanded model and system tests to exercise bets, dealing, dealer behavior, hand-value logic, and UI flows.
- For now the Game model implements locking (`with_lock`) on operations that mutate the deck — this is safe for the single-player flow. If you plan to scale or change concurrency behavior, consider extracting deck logic to a DeckManager service object.

## Troubleshooting

- If CSS seems missing, ensure Tailwind was built and that `app/assets/builds/tailwind.css` is present. Re-run `bin/rails tailwindcss:build` and hard refresh the browser.
- If system tests fail locally, check that a headless browser is available (Chrome/Chromedriver or Firefox/geckodriver) and that the `tmp/screenshots` folder contains helpful failure images.

## Contributing

If you make changes, run the tests and update/add system tests for UI changes. Keep changes small and add unit tests for new logic.

## License

This project is for demonstration and educational use.
