# Todo redesign

Design agreed on 2026-11-10 (grill-me session). This is a new design: it does not reuse the old Todo implementation (`Task`, `TaskManager`, `TodoTag`, the `SpTask*` UI).

The Todo part must work **in isolation from the notes**, since the Note part is being redesigned in parallel. Integration with notes is step 4.

## Vocabulary

- A **task** is a list of **items**. Each task is saved in one file.
- An **item** is one line of a task, never a file of its own.

## Storage

- `NTTaskRepository on: aFolderReference` manages a folder of task files. It knows nothing about where the folder comes from.
- For now, the app has its own **Tasks folder** setting. Once notes are integrated, it defaults to `<notes folder>/todos`.
- File names have an ISO date prefix, like notes: `2026-11-04_pharo14_release.md`.
- **Files never move**, whatever their status.

## Task file format

```
{
  "title" : "Pharo 14 release",
  "section" : "Pharo",
  "status" : "open",
  "creationDate" : "2026-11-04T10:00:00+01:00",
  "lastModificationDate" : "2026-11-09T18:20:00+01:00"
}

- [x] Freeze API @done(2026-11-02)
- [ ] Write release notes @due(2026-11-15) @prio(high) #release
  Mention the new compiler.
  Link the changelog.
- [ ] Sign-off @waitingOthers(Marcus)
```

- An item is a checkbox line: `- [ ]` (open) or `- [x]` (done), then the title, `@key(value)` fields and `#tag`s.
- The lines indented under an item are its description.
- The order of the items in the file is their order in the UI.
- A later session will extend Microdown itself to understand `[x]` and `@key(...)`.

### Metadata

| Field | Meaning |
|---|---|
| `title` | task title |
| `section` | the one UI section the task belongs to (free text); missing means "Unsorted" |
| `status` | `open` (default), `finished` or `abandoned` |
| `finishedDate` | written together with `finished` |
| `creationDate`, `lastModificationDate` | timestamps |

### Item keys

Every `@key(value)` and `@key` is stored generically and written back unchanged. These keys have a meaning in the app:

| Key | Meaning |
|---|---|
| `@due(date)` | optional due date, no default |
| `@done(date)` | added automatically when the item is ticked |
| `@created(date)` | added automatically when the item is created |
| `@start(date)` | the item is hidden from views until that date |
| `@prio(high\|low)` | no key means normal priority |
| `@waitingOthers` / `@waitingOthers(name)` | waiting on someone; feeds the "Waiting for others" view |
| `@note(file.md)` | link to a note (only stored until step 4) |
| `@url(…)` | clickable link |
| `@every(…)` | recurrence: stored now, the behaviour comes later |

There is no trash (delete the line, git keeps history), no separate priority field beyond `@prio`, and no `@estimate`. A richer set of keys may come later.

## Status rules

- When all items are `[x]` and there is at least one item, the app writes `finished` and `finishedDate`.
- When an item is added or unticked, the status goes back to `open` and `finishedDate` is removed.
- `abandoned` is only set by hand and is never changed automatically.
- When a file is loaded, the items win over a stale status, except for `abandoned`.
- `NTTask>>updateStatus` runs before every save.

## Sections

- The list of sections is built from the task files. It is sorted alphabetically, then "Unsorted", then "Finished / Abandoned".
- Finished and abandoned tasks appear only in the special section. They keep their `section` value, so they go back there if reopened.

## Views

Views are configurations, with no query language. They are stored in `<tasks folder>/views.md`:

```
{
  "views" : [
    { "name" : "Today", "period" : "today" },
    { "name" : "This week", "period" : "week" },
    { "name" : "Monthly review", "period" : "month", "includeNoDue" : true, "groupBy" : "task" },
    { "name" : "Late", "period" : "overdue" },
    { "name" : "Waiting for others", "has" : [ "waitingOthers" ], "groupBy" : "waitingOthers" }
  ]
}
```

| Field | Values |
|---|---|
| `sections` | list of section names; missing means all sections |
| `tags` | the items must have all of these tags |
| `period` | `today`, `week`, `month` (calendar), `next N days`, `overdue`; applies to `@due` (or `@start`) |
| `includeNoDue` | also show items with no due date |
| `has` | the items must have these keys, e.g. `waitingOthers`, `prio(high)` |
| `done` | default false |
| `groupBy` | `task`, `section`, `waitingOthers` |
| `sortBy` | `due`, `prio`, `created` |

- A view lists items, and each item shows its task. You can tick items in a view, and the change is saved to the task file.
- Items with a future `@start` are hidden. Finished and abandoned tasks are excluded.
- A plain text filter field (a word or a `#tag`) narrows the current display. It is never saved.

## UI

```
Views                      │  Pharo 14 release   section: [Pharo ▾]  status: open  [List | Text]
  Today              4     │  [x] Freeze API                @done(2026-11-02)
  This week          9     │  [ ] Write release notes       @due(2026-11-15) !
  Monthly review    23     │  [ ] Sign-off                  @waitingOthers(Marcus)
  Late               2     │  [+ add item]
  Waiting for others 3     │
Tasks                      │
  Pharo                    │
    Pharo 14 release 2/3   │
  Unsorted                 │
  Finished / Abandoned     │
```

- **List tab:**
  - Click a title to edit it in place, and press Enter to add the next item.
  - Drag items to reorder them.
  - A side panel shows the description, a widget for each known key (date pickers, a priority menu, …) and `key = value` rows for unknown keys.
  - A "New view…" form edits view configurations.
- **Text tab:** the raw file. Switching back to List parses it; lines that can't be parsed are highlighted and the switch is refused.

## Saving and git

- Every change is written to its file immediately.
- Commits are automatic and batched: after about 2 minutes idle, when switching task, and when closing the app. They go to the git repository that contains the tasks folder, if there is one.
- Commit messages are generated, for example `tasks: Pharo 14 release — ticked "Freeze API", added "Sign-off"`.
- If a file changed on disk since it was loaded, it is reloaded. The app warns only when both sides changed.

## Notes integration (step 4, later)

- Under each note, a strip lists the items whose `@note` points to that note. They can be ticked there, and the strip is hidden when no item links to the note.
- "Create item from selection": the selected text becomes the title and `@note` is filled in.
- The app never writes into notes. When a linked note is deleted, its items show "missing note".
- There is one shared tag vocabulary for notes and items, matched by name.
- Notes are reached only through the `NTNoteDirectory` protocol ("does note X exist", "note tags"). Until step 4 it has a "no notes" implementation.

## Packages and classes

```
TheNoteTaker-Tasks
  NTTask            title, section, status, finishedDate, dates, items, otherMetadata, fileReference
  NTTaskItem        title, description, isDone, annotations (ordered) + accessors (due, start, prio…)
  NTItemKey         @name(value) or @name
  NTItemTag         #name
  NTTaskRepository  on: aFolder; tasks, reload, newTaskTitled:at:, save:at:, remove:,
                    sectionNames, openTasksInSection:, closedTasks, allTags, unreadableFiles
  NTTaskReader      text  -> NTTask (signals NTTaskParseError with the line number)
  NTTaskWriter      NTTask -> text (LF line endings)
  NTItemView        one view configuration; select/group/sort items
  NTItemViewSet     views.md read/write, the default views
  NTTaskCommitter   batched git commits
  NTNoteDirectory   protocol for the notes (+ "no notes" implementation)
TheNoteTaker-Tasks-UI      Spec presenters
TheNoteTaker-Tasks-Tests   round trips, status rules, views, repository on FileSystem memory
```

## Build order

1. **Model and format:** `NTTask`, `NTTaskItem`, reader and writer, status rules and repository. Round-trip tests.
2. **Tasks pane:** the section tree, the special section, the List and Text editor, saving on every change.
3. **Views:** `NTItemView`, `NTItemViewSet`, the view list, the "New view…" form, the filter field.
4. **Notes integration and git:** once the new Note part exists.

**Later sessions:** the `@every` behaviour, the Microdown `[x]` and `@key` extension, and migration of old todo data.
