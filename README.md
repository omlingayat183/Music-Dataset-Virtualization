# Music Dataset Virtualization (Flutter + BLoC)

A Flutter app that virtualizes a massive music dataset (50,000+ tracks) with lazy paging, grouping + sticky headers, non-blocking search, and on-demand details + lyrics fetch.

## App Goal
Build a Flutter music library app that can smoothly display 50,000+ tracks using lazy loading, allow search + grouping, and show track details + lyrics, while keeping memory usage stable.

## Features Implemented
- Infinite scrolling, paged fetch from Deezer Search API.
- Multi-query strategy (`a-z`, `0-9`, common terms) to grow dataset beyond 50k.
- Grouping by first letter of **track** or **artist**.
- Sticky group headers via pinned `SliverPersistentHeader`.
- Debounced search with background isolate filtering to avoid UI jank.
- Details screen with Deezer details + LRCLIB cached lyrics fetch.
- Offline handling with exact message: **"NO INTERNET CONNECTION"**.
- Clear loading/error/success states on both screens.
- Memory stabilization strategy via capped in-memory list (`maxStored = 55,000`) and lazy widget build.

## Architecture (BLoC only)

### BLoC flow summary

#### `LibraryBloc`
Events:
- `LibraryStarted`
- `LibraryFetchNextPage`
- `LibrarySearchChanged`
- `LibraryGroupByChanged`

States:
- `LibraryStatus.initial`
- `LibraryStatus.loading`
- `LibraryStatus.success`
- `LibraryStatus.failure`

Flow:
1. `LibraryStarted` fetches first page.
2. Scroll near end dispatches `LibraryFetchNextPage`.
3. Bloc rotates through seed queries and page offsets.
4. De-dupes by track ID and appends incrementally.
5. Search input dispatches `LibrarySearchChanged`; filtering runs in isolate.
6. UI renders grouped slivers with sticky headers.

#### `TrackDetailsBloc`
Event:
- `TrackDetailsRequested(trackId)`

States:
- `TrackDetailsStatus.initial/loading/success/failure`

Flow:
1. Fetch track details from Deezer `/track/{id}`.
2. Fetch lyrics from LRCLIB cached endpoint.
3. Emit success with combined data or failure with explicit message.

## Why this approach works
- **Lazy build**: `CustomScrollView` + `SliverList.builder` creates visible list cells only.
- **Paging strategy**: fixed-size page pulls (`limit=50`), next page only when near bottom, never preloads 50k widgets.
- **Search strategy**: debounce + isolate filtering keeps main thread responsive.
- **Memory stability**: list is capped to prevent unbounded growth during repeated scroll/search sessions.

## Offline handling
When network is unavailable during list/details/lyrics fetch, app shows exactly:

`NO INTERNET CONNECTION`

## 3 design decisions
1. **Pinned sliver headers** over package-based virtualization/sticky tools to respect constraint (no virtualization plugins).
2. **Client-side search over loaded window** (debounced + isolate) to avoid high-latency server roundtrips and UI freeze.
3. **Bounded in-memory cache** (55k) with dedupe set rebuild when trimming to keep memory stable over long sessions.

## 1 issue faced + fix
- **Issue**: Search stuttered when filtering many loaded tracks on each keystroke.
- **Fix**: Added 300ms debounce and moved filtering work to an isolate (`Isolate.run`).

## What breaks at 100k and next optimizations
At 100k+, current in-memory grouping/filtering costs increase and background filter latency may become noticeable.

Next optimizations:
- Maintain pre-indexed tokens / trie-like local index for faster query filtering.
- Persist pages to local storage (Hive/Isar) and keep only active windows in RAM.
- Use incremental diff updates for grouping maps rather than rebuild-per-state.
- Add cancelable request orchestration and smarter query scheduling.

## How to run
```bash
flutter pub get
flutter run
```

## Demo checklist
- Smooth scroll past large dataset.
- Grouping + sticky headers visible.
- Search input remains responsive.
- Memory behavior observable in DevTools (stable after long scroll/search).
- Tap track -> details + lyrics loaded.
- Disable internet -> message "NO INTERNET CONNECTION".

## Submission
- GitHub repository link: _add after push_
- Video (1-2 min): https://example.com/replace-with-screen-recording
