"
Tests of `NTTaskRepository` on an in-memory file system, so they never touch real notes.
"
Class {
	#name : 'NTTaskRepositoryTest',
	#superclass : 'NTTaskTestCase',
	#instVars : [
		'folder',
		'repository'
	],
	#category : 'TheNoteTaker-Tasks-Tests',
	#package : 'TheNoteTaker-Tasks-Tests'
}

{ #category : 'helpers' }
NTTaskRepositoryTest >> finish: aTask [

	(aTask addItemTitled: 'done' on: (self nov: 4)) markDoneOn: (self nov: 5).
	repository save: aTask at: (self timeOn: 5)
]

{ #category : 'helpers' }
NTTaskRepositoryTest >> newTask: aTitle section: aSection [

	| task |
	task := repository newTaskTitled: aTitle at: (self timeOn: 4).
	task section: aSection.
	repository save: task at: (self timeOn: 4).
	^ task
]

{ #category : 'running' }
NTTaskRepositoryTest >> setUp [

	super setUp.
	folder := FileSystem memory root / 'todos'.
	repository := NTTaskRepository on: folder
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testAllTags [

	| a b |
	a := self newTask: 'Fix CI' section: 'Pharo'.
	(a addItemTitled: 'x' on: (self nov: 4)) addTag: 'work'.
	b := self newTask: 'Write paper' section: 'Research'.
	(b addItemTitled: 'y' on: (self nov: 4))
		addTag: 'work';
		addTag: 'paper'.
	self assert: repository allTags asArray equals: #( 'paper' 'work' )
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testClosedTasks [

	| office grant |
	self newTask: 'Fix CI' section: 'Pharo'.
	office := self newTask: 'Move office' section: 'Admin'.
	self finish: office.
	grant := self newTask: 'Old grant' section: 'Research'.
	grant abandon.
	repository save: grant at: (self timeOn: 6).
	self assert: repository closedTasks asSet equals: {
			office.
			grant } asSet
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testDefaultNoteDirectoryKnowsNoNotes [

	self assert: (repository noteDirectory isKindOf: NTNoNoteDirectory)
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testFilesNeverMove [

	| task file |
	task := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	file := task fileReference.
	task title: 'Fix the CI on Linux'.
	self finish: task.
	self assert: task fileReference equals: file.
	self assert: (folder files collect: [ :each | each basename ] as: Array) equals: #( '2026-11-04_fix_ci.md' )
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testMissingFolderHasNoTasks [

	self assert: repository tasks isEmpty
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testNewTaskCreatesIsoNamedFile [

	| task |
	task := repository newTaskTitled: 'Pharo 14 release!' at: (self timeOn: 4).
	self assert: task fileReference basename equals: '2026-11-04_pharo_14_release.md'.
	self assert: task fileReference exists.
	self assert: task creationDate equals: (self timeOn: 4).
	self assert: (repository tasks includes: task)
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testNewTaskWithEmptyTitleIsNamedUntitled [

	| task |
	task := repository newTaskTitled: '???' at: (self timeOn: 4).
	self assert: task fileReference basename equals: '2026-11-04_untitled.md'
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testNewTaskWithSameNameGetsUniqueFile [

	| first second |
	first := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	second := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	self assert: first fileReference basename equals: '2026-11-04_fix_ci.md'.
	self assert: second fileReference basename equals: '2026-11-04_fix_ci_2.md'
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testNonMarkdownFilesAreIgnored [

	self write: 'hello' to: 'notes.txt'.
	self assert: repository tasks isEmpty
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testOpenTasksAreInFileNameOrder [

	| zebra apple done |
	zebra := repository newTaskTitled: 'Zebra' at: (self timeOn: 4).
	done := repository newTaskTitled: 'Done' at: (self timeOn: 4).
	done abandon.
	apple := repository newTaskTitled: 'Apple' at: (self timeOn: 4).
	self assert: repository openTasks asArray equals: {
			apple.
			zebra }
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testOpenTasksInSection [

	| ci release |
	ci := self newTask: 'Fix CI' section: 'Pharo'.
	release := self newTask: 'Release' section: 'Pharo'.
	self newTask: 'Write paper' section: 'Research'.
	self finish: release.
	self assert: (repository openTasksInSection: 'Pharo') asArray equals: { ci }
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testOpenTasksInUnsorted [

	| cables |
	cables := self newTask: 'Buy cables' section: nil.
	self newTask: 'Fix CI' section: 'Pharo'.
	self assert: (repository openTasksInSection: 'Unsorted') asArray equals: { cables }
]

{ #category : 'tests - views' }
NTTaskRepositoryTest >> testReadingTasksKeepsViews [

	| views |
	views := repository views.
	repository tasks.
	self assert: repository views identicalTo: views
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testReloadReadsExternalFile [

	self
		write: (self text: '- [ ] Call Bob
')
		to: '2026-11-07_call.md'.
	repository reload.
	self assert: repository tasks size equals: 1
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testReloadReadsSavedTasks [

	| task other |
	task := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	task addItemTitled: 'Update the image' on: (self nov: 4).
	repository save: task at: (self timeOn: 6).
	other := NTTaskRepository on: folder.
	self assert: other tasks size equals: 1.
	self assert: other tasks first title equals: 'Fix CI'.
	self assert: other tasks first items first title equals: 'Update the image'.
	self assert: other tasks first fileReference equals: task fileReference
]

{ #category : 'tests - views' }
NTTaskRepositoryTest >> testReloadRereadsViewsFile [

	repository views.
	folder ensureCreateDirectory.
	folder / 'views.md' writeStreamDo: [ :s | s nextPutAll: '{ "views" : [ { "name" : "Mine" } ] }' ].
	repository reload.
	self assert: (repository views views collect: [ :each | each name ] as: Array) equals: #( 'Mine' )
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testRemoveDeletesFile [

	| task |
	task := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	repository remove: task.
	self deny: task fileReference exists.
	self assert: repository tasks isEmpty
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testSaveSetsLastModificationDate [

	| task |
	task := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	repository save: task at: (self timeOn: 6).
	self assert: task lastModificationDate equals: (self timeOn: 6)
]

{ #category : 'tests - errors' }
NTTaskRepositoryTest >> testSaveTaskOfAnotherFolderRaisesError [

	| other task |
	other := NTTaskRepository on: FileSystem memory root / 'other'.
	task := other newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	self should: [ repository save: task at: (self timeOn: 5) ] raise: Error
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testSaveUpdatesStatus [

	| task |
	task := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	self finish: task.
	self assert: task isFinished.
	self assert: (task fileReference contents includesSubstring: '"status" : "finished"')
]

{ #category : 'tests - views' }
NTTaskRepositoryTest >> testSaveViewsWritesViewsFile [

	repository views add: (NTItemView named: 'Pharo only').
	repository saveViews.
	self assert: (folder / 'views.md') contents equals: repository views text
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testSaveWritesFile [

	| task |
	task := repository newTaskTitled: 'Fix CI' at: (self timeOn: 4).
	task addItemTitled: 'Update the image' on: (self nov: 4).
	repository save: task at: (self timeOn: 6).
	self assert: task fileReference contents equals: (NTTaskWriter write: task)
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testSectionNames [

	self newTask: 'Write paper' section: 'Research'.
	self newTask: 'Buy cables' section: nil.
	self newTask: 'Fix CI' section: 'Pharo'.
	self newTask: 'Release' section: 'Pharo'.
	self assert: repository sectionNames asArray equals: #( 'Pharo' 'Research' 'Unsorted' )
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testSectionNamesIgnoreClosedTasks [

	self newTask: 'Fix CI' section: 'Pharo'.
	self finish: (self newTask: 'Move office' section: 'Admin').
	self assert: repository sectionNames asArray equals: #( 'Pharo' )
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testTasksAreSortedByFileName [

	self
		write: (self text: '{
  "title" : "B"
}
')
		to: '2026-11-07_b.md'.
	self
		write: (self text: '{
  "title" : "A"
}
')
		to: '2026-11-02_a.md'.
	self assert: (repository tasks collect: [ :each | each title ] as: Array) equals: #( 'A' 'B' )
]

{ #category : 'tests' }
NTTaskRepositoryTest >> testUnreadableFileIsSkipped [

	self
		write: (self text: 'not a task
')
		to: '2026-11-07_bad.md'.
	self
		write: (self text: '- [ ] Call Bob
')
		to: '2026-11-07_call.md'.
	self assert: repository tasks size equals: 1.
	self assert: (repository unreadableFiles collect: [ :each | each key basename ] as: Array) equals: #( '2026-11-07_bad.md' )
]

{ #category : 'tests - errors' }
NTTaskRepositoryTest >> testUnreadableViewsFileGivesDefaultsAndError [

	| other |
	folder ensureCreateDirectory.
	folder / 'views.md' writeStreamDo: [ :s | s nextPutAll: '{ "views" : [ { "period" : "today" } ] }' ].
	other := NTTaskRepository on: folder.
	self assert: other views views size equals: NTItemViewSet defaults views size.
	self assert: other viewsError messageText equals: 'a view has no name'
]

{ #category : 'tests - views' }
NTTaskRepositoryTest >> testViewsAreDefaultsWithoutViewsFile [

	self
		assert: (repository views views collect: [ :each | each name ] as: Array)
		equals: (NTItemViewSet defaults views collect: [ :each | each name ] as: Array).
	self deny: (folder / 'views.md') exists
]

{ #category : 'tests - views' }
NTTaskRepositoryTest >> testViewsAreReadFromViewsFile [

	folder ensureCreateDirectory.
	folder / 'views.md' writeStreamDo: [ :s | s nextPutAll: '{ "views" : [ { "name" : "Mine", "period" : "week" } ] }' ].
	self assert: ((NTTaskRepository on: folder) views viewNamed: 'Mine') period equals: 'week'
]

{ #category : 'tests - views' }
NTTaskRepositoryTest >> testViewsFileIsNotATask [

	repository views add: (NTItemView named: 'Pharo only').
	repository saveViews.
	repository reload.
	self assert: repository tasks isEmpty.
	self assert: repository unreadableFiles isEmpty
]

{ #category : 'helpers' }
NTTaskRepositoryTest >> write: aString to: aFileName [
	"Write a task file by hand, as an external editor or git would."

	folder ensureCreateDirectory.
	folder / aFileName writeStreamDo: [ :stream | stream nextPutAll: aString ]
]
