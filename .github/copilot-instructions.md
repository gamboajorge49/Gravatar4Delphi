# Copilot instructions for Gravatar4Delphi

## Build, test, lint
- **Dependencies:** `boss install github.com/gamboajorge49/Gravatar4Delphi.git`
- **Build package:** open `src\Gravatar4Delphi.dproj` (or `src\Gravatar4Delphi.dpk`) in Delphi and build.
- **Run tests:** open `Test\Gravatar4DelphiTests.dproj` and run. The project supports GUI runner by default; add `CONSOLE_TESTRUNNER` in project conditional defines to use the console runner.
- **Run a single test:** in the DUnit GUI runner, expand `TestTGravatar4D` and run the specific test method (e.g., `TestGenerateUrl`).

## High-level architecture
- **Core library:** `src\Gravatar4D.pas` defines `TGravatar4D`, the main entry point. It validates emails, hashes them to MD5, builds Gravatar URLs, and downloads images via `REST.Client` into a `TPicture`.
- **Tests:** DUnit tests live in `Test\TestGravatar4D.pas` and are wired by `Test\Gravatar4DelphiTests.dpr`.
- **Sample app:** `Sample\Gravatar4DelphiSample.dproj` and `Sample\ufrmMain.pas` show UI usage and enum-driven options for rating/default image.

## Key conventions
- **Enum name mapping:** `GenerateUrl` derives query values by stripping the `gr`/`gd` prefix from `TGravatarRating` and `TGravatarDeafult` enum names and lowercasing them. New enum members must follow this naming scheme or the URL builder will break.
- **Default-image handling:** `gdUrlImage` uses `URLDefaultImage` and URL-encodes it with `TIdURI.URLEncode`; all other defaults use the enum-derived token.
- **Exception messages are contract:** tests assert exact `EGravatar4dException` messages for empty/invalid emails. Keep these strings stable or update tests accordingly.
