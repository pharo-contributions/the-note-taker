"
I am an `NT3Application` for tests: I keep the deferred blocks until `runDeferred`, as the UI loop would run them after the current event. My notes folder is in memory and my autosave timer is an `NT3ManualTimer`, so tests never write to disk nor wait.
"
Class {
	#name : 'NT3DeferringTestApplication',
	#superclass : 'NT3Application',
	#instVars : [
		'deferredBlocks'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'ui' }
NT3DeferringTestApplication >> defer: aBlock [
	"Keep aBlock until runDeferred, as the UI loop would run it after the current event"

	deferredBlocks ifNil: [ deferredBlocks := OrderedCollection new ].
	deferredBlocks add: aBlock
]

{ #category : 'initialization' }
NT3DeferringTestApplication >> initialize [

	super initialize.
	self
		notesFolder: FileSystem memory root / 'Notes';
		autosaveTimer: NT3ManualTimer new
]

{ #category : 'ui' }
NT3DeferringTestApplication >> runDeferred [

	| blocks |
	blocks := deferredBlocks ifNil: [ #(  ) ].
	deferredBlocks := nil.
	blocks do: [ :each | each value ]
]
