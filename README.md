# Questlings

A habit tracker that plays like a creature-collecting game. Pick a companion, tie your real-world habits to it,
and keep it healthy by actually doing them. Miss days and your bond decays; keep a streak and it evolves.

Built with Flutter and Supabase by team **CutePalz**.

## How it plays

- **Four starter companions**, one per habit category: Sports-ling, Skool-ling, Art-ling and Tech-ling.
- **A bond meter instead of HP.** Missed habits drain the bond: a base loss for the first missed day, plus a
  penalty that grows with every consecutive missed day and with the Questling's maturity. Let it fall too low
  and your Questling "glitches" until you win it back with care tasks.
- **Evolution through streaks**: Hatchling → Rookie → Champion → Mega.
- **Parties**: team up with friends and work toward shared goals.
- **Shop**: spend what you earn on items for your Questlings.

The full rules, including the decay formula, are in [`docs/game_system_doc.md`](docs/game_system_doc.md).

## Screens

| Feature | Code |
|---|---|
| Sign-in, username and first-time setup | `lib/features/auth/` |
| Daily habits and evolution | `lib/features/home/` |
| Questling collection | `lib/features/inventory/` |
| Party and social features | `lib/features/party/` |
| Shop | `lib/features/shop/` |

## Tech stack

Flutter (Dart 3), Supabase (auth and Postgres), Riverpod for state, GoRouter for navigation, Google Sign-In,
and `flutter_dotenv` for configuration.

## Running it

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and create a Supabase project.
2. Set up the database with the SQL files in the repo root (`updated_schema.sql` and the feature migrations
   next to it). The tables are described in [`docs/schema.md`](docs/schema.md).
3. Create a `.env` file in the project root with your project's public values:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
   `.env` is gitignored. Only ever use the **anon** key here, never the service-role key.
4. Install dependencies and run:
   ```sh
   flutter pub get
   flutter run
   ```

## Documentation

- [Design specification](docs/docs.md)
- [Game system and bond logic](docs/game_system_doc.md)
- [Database schema](docs/schema.md)
- [UI specifications](docs/ui_specs.md)
- [Type and habit mapping](docs/types_mapping.md)
- [System flow](docs/system_flow.md)
- [Implementation roadmap](docs/implementation_roadmap.md)
- [Visual design system](Design.md)

## Team CutePalz

[@D3vala](https://github.com/D3vala), [@10Plaiz](https://github.com/10Plaiz), [@D0tSM3](https://github.com/D0tSM3)
and [@Zel143](https://github.com/Zel143).
