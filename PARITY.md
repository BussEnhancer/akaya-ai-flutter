# Akaya UI parity

Flutter visual port of [india0080/Akaya-ai-bot](https://github.com/india0080/Akaya-ai-bot) (`app/`, React + Vite + Capacitor `one.akaya.app`, v0.5.0).

This folder is UI and mock data only. It does not call Firebase, the Akaya API, or device speech. The existing `akaya_ai/` app is unchanged.

| React route | Flutter | Status |
| --- | --- | --- |
| `/signup` | `SignUpScreen` | done — Google, email, and phone tabs, demo badge, orange CTA |
| `/login` | `LoginScreen` | done |
| `/forgot` | `ForgotScreen` | done |
| `/verify-email` | `VerifyScreen` | done — demo “mark as verified”; no real inbox |
| `/onboarding` | `OnboardingScreen` | done — same 5 slides, copy, and stage marks. Entrances use the Framer spring (`stiffness: 260`, `damping: 20`) and the default scale spring (`550/30`) plus the 300ms opacity ease. `?anim=<ms>` freezes the loop at that time. The finger follows the React SVG path over 350ms |
| `/home` | `HomeScreen` | done — greeting, mode, pearl, ask pill, bento, Today, apps, feature cards, recent chats. Today counts use the sample rows |
| Home sheets (`?sheet=`) | notifications, read, read-done, today, agents, explore, loan | done — bill sample and “Akaya explains”, today rows, explore prompts, EMI calculator (₹1,00,000 / 12 months / 14% illustrative) |
| `/chat`, `/chat/:id` | `ChatScreen` | done — header, empty state, suggestions, bubbles, composer, attach sheet (`?attach=1`), ask-your-apps panel (`?panel=apps`), mock attachment chips, and commerce link cards |
| `/voice` | `VoiceScreen` | done — idle, listening demo, thinking, speaking, and microphone-blocked states. The mic button shows the blocked state; Demo runs the scripted line. No Web Speech or microphone |
| `/more` | `MoreScreen` | done — profile, upgrade, apps, link grid, theme, text size, mode, language, voice, notifications, logout |
| `/translate` | `TranslateScreen` | done — phrasebook, swap, and the bundled sample phrases |
| `/notes` | `NotesScreen` | done — composer, colours, search, delete |
| `/search` | `SearchScreen` | done — feature list plus chat and note matches |
| `/history` | `HistoryScreen` | done — filters (`?f=`), search (`?q=`), row menu (`?menu=1`), detail sheet (`?detail=1`), pin, delete |
| `/future` | `FutureScreen` | done — queue and sent, composer (channels, quick times, repeat), edit, send now, cancel. Saved in memory only |
| `/upgrade` | `UpgradeScreen` | done — monthly/yearly sample prices |
| `/apps` | `AppsScreen` + connect sheet | done — all 264 catalog apps, region and category filters, search, and the detail → consent → connecting → connected sheet (simulated sign-in). All 210 SVGs from `logos.generated.ts` are used; the rest are monograms |
| `/support` | `SupportScreen` | done — FAQs and contact form |
| `/travel` | `TravelScreen` | done — stays, flights, things to do, editable dates, search, and a copy-link sheet. No live partner search |
| `/shopping` | `ShoppingScreen` | done — stores, category chips, sample deals, and a link sheet that copies the store search URL |
| `/earnings` | `EarningsScreen` | done — same platforms, period scale, and pending split as `sampleEarnings` + `summarize()` (newest ~30% of orders pending) |
| `/reminders` | `RemindersScreen` | done — upcoming / completed / missed, search, category, priority, sort, smart follow-up, quick add. Times shown in IST. The `@akaya/reminders` scheduling engine is not bundled |
| `/vnotes` | `VoiceNotesScreen` | done — modes, live demos, recent list (`?view=recent` scrolls to the recordings) |
| `/vnotes/rec` | `RecorderScreen` | done — lecture and business demos, notes / transcript / mind-map tabs. `?hold=1` freezes a filled transcript. The mind-map tab is the React branching tree (spine, topic pills, dashed idea chips). Tap a topic to fold it; tap an idea to mark it. No live mic |
| `/vnotes/:id` | `NoteViewScreen` | done — playback, transcript, notes, summary, the same branching mind map, actions. `?line=hindi` highlights the Diwali Hindi line |

Shared pieces: light/dark tokens, Comfortaa + Manrope + Noto Sans Devanagari, brand and orange gradients, 123 SVG icons, phone frame (390×844, radius 52) at ≥600×760, status-bar clock via `?clock=`, pearl painter (idle / happy / listening / thinking / sleeping, seeded blink, float, listen rings, thinking lid, optional gaze). `?anim=<ms>` freezes the pearl and the onboarding timeline at that millisecond.

What is close but not the same pixels: the pearl now uses the canvas stack (focal glow, blurred film bands, half-alpha `BlendMode.softLight` sweep, bright rim, blurred highlight, specular). At the same timestamp the pose matches, including the seeded blink (eyes open at 400ms, shut at 1600ms, open again at 2400ms). Skia’s soft-light and blur are not the browser’s canvas pixels, so a still of the orb still differs by a few levels. Onboarding stages match at 0 / 400 / 1000 / 1800 / 3600 / 4200ms; a mid-spring frame can sit a couple of pixels off because Flutter uses the closed-form spring and Framer integrates per frame. The lecture mind map is the CSS tree, not a free-form canvas, which is what React draws. Scroll-position shots (home bottom, more bottom, history bottom, apps list bottom, your apps, voice-notes tile, voice-notes recent) are the same screen scrolled, not separate layouts.

## Light-theme design sheet

Source: `design/app-screens/screens-light.png` in india0080/Akaya-ai-bot. The sheet header says **58 screens** at 390×844. Every number below is a reachable Flutter route. Signed-in previews add `?preview=1&theme=light&clock=9:41`. Signup and OTP stay signed out.

| # | Sheet name | Flutter route / state | Status |
| --- | --- | --- | --- |
| 01 | Signup | `/signup` | done |
| 02 | OTP code | `/signup?step=otp` | done — 6 boxes, demo hint, resend held at 0:29 for the preview |
| 03 | Onboarding 1 | `/onboarding?slide=0` | done — `?anim=` freezes the floating-reply spring |
| 04 | Onboarding 2 | `/onboarding?slide=1` | done |
| 05 | Onboarding 3 | `/onboarding?slide=2` | done |
| 06 | Onboarding 4 | `/onboarding?slide=3` | done |
| 07 | Onboarding 5 | `/onboarding?slide=4` | done |
| 08 | Home | `/home` | done |
| 09 | Home bottom | `/home?scroll=bottom` | done |
| 10 | Sheet: notifications | `/home?sheet=notifications` | done |
| 11 | Sheet: read | `/home?sheet=read` | done — sample City Power bill, before the explanation |
| 12 | Sheet: read done | `/home?sheet=read-done` | done — Akaya explains the ₹1,240 bill |
| 13 | Sheet: today | `/home?sheet=today` | done — reminders link plus sample events and follow-ups |
| 14 | Sheet: agents | `/home?sheet=agents` | done |
| 15 | Sheet: explore | `/home?sheet=explore` | done |
| 16 | Sheet: loan | `/home?sheet=loan` | done — EMI at ₹1,00,000 / 12 months |
| 17 | Chat empty | `/chat` | done |
| 18 | Chat thread | `/chat/c-goa` | done |
| 19 | Voice | `/voice` | done — idle voice screen; listening, thinking, speaking, and blocked are on the same screen |
| 20 | More | `/more` | done |
| 21 | More bottom | `/more?scroll=bottom` | done |
| 22 | Translate | `/translate` | done |
| 23 | Future | `/future` | done |
| 24 | Notes | `/notes` | done |
| 25 | Search | `/search` | done |
| 26 | History | `/history` | done |
| 27 | History: Floating filter | `/history?f=floating` | done |
| 28 | History: search | `/history?q=neha` | done |
| 29 | History menu | `/history?menu=1` | done — Open / Pin / Delete on the first row |
| 30 | History detail | `/history?detail=1` | done |
| 31 | History bottom | `/history?scroll=bottom` | done |
| 32 | Upgrade | `/upgrade` | done |
| 33 | Support | `/support` | done |
| 34 | Apps & Integrations | `/apps` | done |
| 35 | Apps: Finance filter | `/apps?cat=finance` | done |
| 36 | Apps: search "mail" | `/apps?q=mail` | done |
| 37 | App detail: Gmail | `/apps?app=gmail&step=detail` | done — Gmail is already connected in the sample |
| 38 | Connect: consent | `/apps?app=notion&step=consent` | done |
| 39 | Connect: connecting | `/apps?app=notion&step=connecting` | done — frozen on “Waiting for your approval” |
| 40 | Connect: connected | `/apps?app=notion&step=done` | done — simulated; no real Notion account |
| 41 | Apps: list (bottom) | `/apps?scroll=bottom` | done |
| 42 | Home: Your apps | `/home?focus=apps` | done |
| 43 | Chat: + menu | `/chat?attach=1` | done |
| 44 | Chat: ask your apps | `/chat?panel=apps` | done |
| 45 | History: Apps filter | `/history?f=app` | done |
| 46 | Voice Notes: modes | `/vnotes` | done |
| 47 | Voice Notes: demos, recent | `/vnotes?view=recent` | done |
| 48 | Live lecture: notes | `/vnotes/rec?demo=lecture&tab=notes&hold=1` | done — mock script, not a microphone |
| 49 | Live lecture: transcript | `/vnotes/rec?demo=lecture&tab=transcript&hold=1` | done |
| 50 | Live lecture: mind map | `/vnotes/rec?demo=lecture&tab=map&hold=1` | done — branching tree from the lecture hints (root “Linear Algebra – Chapter 3”) |
| 51 | Live business meeting | `/vnotes/rec?demo=business&tab=notes&hold=1` | done |
| 52 | Meeting: action items | `/vnotes/vn-sales?tab=actions` | done |
| 53 | Saved note + playback | `/vnotes/vn-calc?play=1` | done |
| 54 | Saved note: summary | `/vnotes/vn-calc?tab=summary` | done |
| 55 | Saved note: actions | `/vnotes/vn-calc?tab=actions` | done |
| 56 | Playback: Hindi line | `/vnotes/vn-diwali?tab=transcript&line=hindi` | done — “दिवाली पर परिवार के साथ…” |
| 57 | Home: Voice Notes tile | `/home?focus=vnotes` | done |
| 58 | History: Voice Notes | `/history?f=vnote` | done |

Nothing on the sheet is missing a route. The lecture mind map is the same branching tree React draws. The pearl glow follows the canvas composite; Skia and the browser still do not rasterise soft-light and blur to identical pixels.
