APP STORE CONNECT — copy-paste snippets
=======================================
Open each .txt and paste its whole contents into the matching field.

FILE                       ASC FIELD                          LIMIT      USED
-------------------------------------------------------------------------------
01_name.txt                App Information > Name              30          12
02_subtitle.txt            App Information > Subtitle          30          28
03_promotional_text.txt    Version > Promotional Text          170        165
04_description.txt         Version > Description               4000       2470
05_keywords.txt            Version > Keywords                  100         99
06_whats_new.txt           Version > What's New                4000        865
07_support_url.txt         Version > Support URL               -            -
08_marketing_url.txt       Version > Marketing URL (optional)  -            -
09_privacy_policy_url.txt  App Privacy > Privacy Policy URL    -            -
10_copyright.txt           App Information > Copyright         -            -
11_review_notes.txt        App Review Information > Notes      -            -
12_privacy_answers.txt     App Privacy questionnaire (guide)  -            -

OTHER FIELDS (no paste needed)
- Primary category: Food & Drink   | Secondary (optional): Lifestyle
- Age rating: 4+  (answer "None" to every content question)
- Price: Free (Tier 0)
- Build to attach: 1.1 (38+)   (iPhone-only) — see note below, NOT build 37
- Export compliance: not asked (ITSAppUsesNonExemptEncryption = NO)

⚠️ BUILD NUMBER — READ BEFORE SUBMITTING
The last CLI archive/upload was 1.1 build 37. Several commits landed after
that (mini-tile mode picker, video loop cap, mushroom/nutella/banana/peppers
topping videos) that build 37 does NOT contain. Bump CURRENT_PROJECT_VERSION
to 38, re-run the CLI archive (see kneady-pizza-release-workflow memory /
APP_STORE_SUBMISSION.md), upload it, then select THAT build in App Store
Connect — TestFlight also rejects re-uploading a duplicate build number.

SCREENSHOTS
- iPhone 6.9" (1320x2868) or 6.7" (1290x2796); 6.5" (1242x2688) also accepted.
- iPhone-only app -> no iPad screenshots needed.
- Capture in the iPhone 17 Pro Max simulator: Cmd+S saves a correct-size PNG;
  Cmd+Left rotates for the landscape cooking-mode shot.
- screenshots/kid-1-pick.png, kid-2-choose-dough.png, kid-3-mix.png were
  captured 28 Jun and are now STALE — Kid Mode's UI has changed a lot since
  (bigger dough cards, step videos, mini-tile mode picker). Recapture before
  uploading, or ask Claude to grab fresh ones from the simulator.

Full walkthrough: ../APP_STORE_SUBMISSION.md  (section 7 is click-by-click)