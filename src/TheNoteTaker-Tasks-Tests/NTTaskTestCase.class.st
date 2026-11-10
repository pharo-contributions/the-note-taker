"
I am the abstract superclass of the tests of TheNoteTaker-Tasks. I provide helpers to build fixed dates (`nov:`) and file texts with LF line endings (`text:`).
"
Class {
	#name : 'NTTaskTestCase',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-Tasks-Tests',
	#package : 'TheNoteTaker-Tasks-Tests'
}

{ #category : 'testing' }
NTTaskTestCase class >> isAbstract [

	^ self == NTTaskTestCase
]

{ #category : 'helpers' }
NTTaskTestCase >> nov: aDay [
	"Answer the date of that day of November 2026, so tests use fixed dates."

	^ Date year: 2026 month: 11 day: aDay
]

{ #category : 'helpers' }
NTTaskTestCase >> text: aString [
	"Answer aString with LF line endings, as task files are written."

	^ aString withUnixLineEndings
]

{ #category : 'helpers' }
NTTaskTestCase >> timeOn: aDay [
	"Answer a fixed time on that day of November 2026."

	^ DateAndTime
		  year: 2026
		  month: 11
		  day: aDay
		  hour: 10
		  minute: 0
		  second: 0
		  offset: 1 hour
]
