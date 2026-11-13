"
I am the abstract test case holding four sample notes for the UI3 tests: old (December 2025, pharo), middle (October 2026, spec and pharo), recent (November 2026, spec) and untagged (November 2026, no tag).
"
Class {
	#name : 'NT3NotesTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'old',
		'recent',
		'middle',
		'untagged'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'testing' }
NT3NotesTestCase class >> isAbstract [
	^ self == NT3NotesTestCase
]

{ #category : 'helpers' }
NT3NotesTestCase >> noteTitled: aTitle at: aString tagNames: aCollection [

	^ NT3Application
		  noteTitled: aTitle
		  body: 'body'
		  modifiedAt: (DateAndTime fromString: aString)
		  tagNames: aCollection
]

{ #category : 'helpers' }
NT3NotesTestCase >> notes [

	^ {
		  old.
		  recent.
		  untagged.
		  middle }
]

{ #category : 'running' }
NT3NotesTestCase >> setUp [

	super setUp.
	old := self noteTitled: 'Old' at: '2025-12-20T10:00:00' tagNames: #( 'pharo' ).
	middle := self noteTitled: 'Middle' at: '2026-10-03T10:00:00' tagNames: #( 'spec' 'pharo' ).
	recent := self noteTitled: 'Recent' at: '2026-11-10T10:00:00' tagNames: #( 'spec' ).
	untagged := self noteTitled: 'Untagged' at: '2026-11-11T10:00:00' tagNames: #(  )
]
