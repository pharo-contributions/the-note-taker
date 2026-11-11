"
I manage the tasks stored in one folder: one task per `.md` file.

## Responsibility:

- I load every task file of my folder, save a task to its file (updating its status and modification date first), and create and delete task files.
- I name new task files with an ISO date prefix and the title (`2026-11-04_pharo14_release.md`); files never move afterwards.
- I answer the sections of the open tasks (alphabetically, then 'Unsorted'), the open tasks in file name order, and the closed tasks (finished or abandoned).
- I read and save the views of the folder in `views.md`, falling back to the default views when it is missing or cannot be read.

## Collaborators: 

- `NTTask`: what I store.
- `NTTaskReader` / `NTTaskWriter`: convert between files and tasks.
- `NTNoteDirectory`: how I reach the notes; `NTNoNoteDirectory` while the todo part runs alone.
- `FileReference`: my folder; tests use `FileSystem memory`.

## Public API and Key Messages

- `NTTaskRepository on: aFolderReference`
- `tasks`, `reload`, `save: aTask`, `newTaskTitled:`, `newTaskTitled:on:`, `remove: aTask`
- `sectionNames`, `openTasks`, `openTasksInSection: aString`, `closedTasks`, `allTags`
- `views` (an `NTItemViewSet`), `saveViews`, `viewsError`

```
| repository |
repository := NTTaskRepository on: FileSystem memory root.
(repository newTaskTitled: 'Pharo 14 release') addItemTitled: 'Freeze API' on: Date today.
repository tasks
```

See `NTTaskRepository class >> #exampleInMemory`.

## Internal Representation

- `folder`: a FileReference.
- `tasks`: an OrderedCollection of `NTTask`, loaded lazily.
- `noteDirectory`: an `NTNoteDirectory`.
- `views`: the `NTItemViewSet`, loaded lazily; `viewsError`: the `NTViewsFormatError` of views.md, or nil.

### Implementation Points

- `views.md` holds the view configurations and is not read as a task. `reload` reads it again on next use.
- Files that cannot be parsed are skipped by `reload`; `unreadableFiles` lists them with their error.
"
Class {
	#name : 'NTTaskRepository',
	#superclass : 'Object',
	#instVars : [
		'folder',
		'tasks',
		'noteDirectory',
		'unreadableFiles',
		'views',
		'viewsError'
	],
	#category : 'TheNoteTaker-Tasks-Model',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Model'
}

{ #category : 'examples' }
NTTaskRepository class >> exampleInMemory [

	<sampleInstance>
	| repository day task |
	repository := self on: FileSystem memory root / 'todos'.
	day := DateAndTime
		       year: 2026
		       month: 11
		       day: 4
		       hour: 10
		       minute: 0
		       second: 0.
	task := repository newTaskTitled: 'Pharo 14 release' at: day.
	task section: 'Pharo'.
	(task addItemTitled: 'Freeze API' on: day asDate) markDoneOn: day asDate.
	task addItemTitled: 'Write release notes' on: day asDate.
	repository save: task at: day.
	^ repository
]

{ #category : 'instance creation' }
NTTaskRepository class >> on: aFolderReference [

	^ self new
		  folder: aFolderReference;
		  yourself
]

{ #category : 'accessing' }
NTTaskRepository class >> untitledName [

	^ 'untitled'
]

{ #category : 'accessing' }
NTTaskRepository class >> viewsFileName [
	"The file of the folder that holds view configurations, not a task."

	^ 'views.md'
]

{ #category : 'queries' }
NTTaskRepository >> allTags [

	^ (self tasks flatCollect: [ :each | each allTags ]) asSet asArray sort
]

{ #category : 'queries' }
NTTaskRepository >> closedTasks [
	"Answer the finished and abandoned tasks, shown in their own special section."

	^ self tasks select: [ :each | each isClosed ]
]

{ #category : 'private' }
NTTaskRepository >> fileWordsOf: aString [

	| words |
	words := (aString asLowercase collect: [ :each |
			          each isAlphaNumeric
				          ifTrue: [ each ]
				          ifFalse: [ Character space ] ]) substrings.
	^ words ifEmpty: [ self class untitledName ] ifNotEmpty: [ $_ join: words ]
]

{ #category : 'accessing' }
NTTaskRepository >> folder [

	^ folder
]

{ #category : 'accessing' }
NTTaskRepository >> folder: aFolderReference [

	folder := aFolderReference.
	tasks := nil
]

{ #category : 'initialization' }
NTTaskRepository >> initialize [

	super initialize.
	noteDirectory := NTNoNoteDirectory new.
	unreadableFiles := OrderedCollection new
]

{ #category : 'private' }
NTTaskRepository >> isFileTaken: aFileReference [

	^ aFileReference exists or: [ self tasks anySatisfy: [ :each | each fileReference = aFileReference ] ]
]

{ #category : 'loading' }
NTTaskRepository >> loadTasks [
	"Read every task file of the folder, in file name order. Files that cannot be read are skipped and listed in unreadableFiles."

	tasks := OrderedCollection new.
	unreadableFiles := OrderedCollection new.
	folder exists ifFalse: [ ^ self ].
	(self taskFiles sorted: [ :a :b | a basename <= b basename ]) do: [ :file |
			[
				tasks add: ((NTTaskReader read: file contents)
						 fileReference: file;
						 yourself) ]
				on: NTTaskParseError
				do: [ :error | unreadableFiles add: file -> error ] ]
]

{ #category : 'views' }
NTTaskRepository >> loadViews [

	viewsError := nil.
	self viewsFile exists ifFalse: [ ^ NTItemViewSet defaults ].
	^ [ NTItemViewSet fromText: self viewsFile contents ]
		  on: NTViewsFormatError
		  do: [ :error |
				  viewsError := error.
				  NTItemViewSet defaults ]
]

{ #category : 'private' }
NTTaskRepository >> newFileForTitle: aString on: aDate [
	"Answer an unused file named yyyy-mm-dd_words_of_the_title.md, adding _2, _3... when the name is taken."

	| base file counter |
	base := '{1}_{2}' format: {
			        aDate yyyymmdd.
			        (self fileWordsOf: aString) }.
	file := folder / ('{1}.md' format: { base }).
	counter := 1.
	[ self isFileTaken: file ] whileTrue: [
			counter := counter + 1.
			file := folder / ('{1}_{2}.md' format: {
					         base.
					         counter }) ].
	^ file
]

{ #category : 'tasks' }
NTTaskRepository >> newTaskTitled: aString [

	^ self newTaskTitled: aString at: DateAndTime now
]

{ #category : 'tasks' }
NTTaskRepository >> newTaskTitled: aString at: aDateAndTime [
	"Create a task, give it a new file named after the date and the title, and save it."

	| task |
	task := NTTask title: aString.
	task creationDate: aDateAndTime.
	task fileReference: (self newFileForTitle: aString on: aDateAndTime asDate).
	self tasks add: task.
	self save: task at: aDateAndTime.
	^ task
]

{ #category : 'accessing' }
NTTaskRepository >> noteDirectory [

	^ noteDirectory
]

{ #category : 'accessing' }
NTTaskRepository >> noteDirectory: aNoteDirectory [

	noteDirectory := aNoteDirectory
]

{ #category : 'queries' }
NTTaskRepository >> openTasks [
	"Answer the open tasks in file name order, the order of the folder."

	^ (self tasks select: [ :each | each isOpen ]) sorted: [ :a :b | a fileReference basename <= b fileReference basename ]
]

{ #category : 'queries' }
NTTaskRepository >> openTasksInSection: aSectionName [

	^ self tasks select: [ :each | each isOpen and: [ each sectionName = aSectionName ] ]
]

{ #category : 'loading' }
NTTaskRepository >> reload [
	"Read every task file of the folder again, and views.md on next use."

	views := nil.
	self loadTasks
]

{ #category : 'tasks' }
NTTaskRepository >> remove: aTask [

	aTask fileReference ifNotNil: [ :file | file ensureDelete ].
	self tasks remove: aTask ifAbsent: [ nil ]
]

{ #category : 'tasks' }
NTTaskRepository >> save: aTask [

	self save: aTask at: DateAndTime now
]

{ #category : 'tasks' }
NTTaskRepository >> save: aTask at: aDateAndTime [
	"Apply the status rules, record the modification time and write the file of aTask. Its file never changes once given."

	| file |
	aTask fileReference ifNil: [
			aTask fileReference: (self newFileForTitle: aTask title on: aDateAndTime asDate).
			self tasks add: aTask ].
	file := aTask fileReference.
	file parent = folder ifFalse: [ ^ self error: ('The task {1} belongs to another folder' format: { aTask title printString }) ].
	aTask updateStatusOn: aDateAndTime asDate.
	aTask lastModificationDate: aDateAndTime.
	folder ensureCreateDirectory.
	file ensureDelete.
	file writeStreamDo: [ :stream | stream nextPutAll: (NTTaskWriter write: aTask) ]
]

{ #category : 'views' }
NTTaskRepository >> saveViews [
	"Write the views in views.md."

	folder ensureCreateDirectory.
	self viewsFile ensureDelete.
	self viewsFile writeStreamDo: [ :stream | stream nextPutAll: self views text ].
	viewsError := nil
]

{ #category : 'queries' }
NTTaskRepository >> sectionNames [
	"Answer the sections of the open tasks, alphabetically, with 'Unsorted' last."

	| unsorted names sorted |
	unsorted := NTTask unsortedSectionName.
	names := (self tasks select: [ :each | each isOpen ] thenCollect: [ :each | each sectionName ]) asSet.
	sorted := (names reject: [ :each | each = unsorted ]) asArray sort.
	^ (names includes: unsorted)
		  ifTrue: [ sorted copyWith: unsorted ]
		  ifFalse: [ sorted ]
]

{ #category : 'loading' }
NTTaskRepository >> taskFiles [

	^ folder files select: [ :each | each extension = 'md' and: [ each basename ~= self class viewsFileName ] ]
]

{ #category : 'accessing' }
NTTaskRepository >> tasks [

	tasks ifNil: [ self loadTasks ].
	^ tasks
]

{ #category : 'accessing' }
NTTaskRepository >> unreadableFiles [
	"Answer the task files the last reload could not read, as file -> NTTaskParseError."

	self tasks.
	^ unreadableFiles
]

{ #category : 'views' }
NTTaskRepository >> views [
	"Answer the views of the folder, read from views.md, or the default views when there is no views.md or it cannot be read (see viewsError)."

	^ views ifNil: [ views := self loadViews ]
]

{ #category : 'views' }
NTTaskRepository >> viewsError [
	"Answer the NTViewsFormatError of views.md when it could not be read, or nil."

	^ viewsError
]

{ #category : 'views' }
NTTaskRepository >> viewsFile [

	^ folder / self class viewsFileName
]
