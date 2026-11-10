"
I am the only way the tasks reach the notes. I am abstract: the notes side provides a concrete subclass.

## Responsibility:

- I answer whether a note exists, so an item's `@note(...)` link can be shown as valid or as ""missing note"".
- I answer the tags used on notes, so notes and items share one tag vocabulary.
- I keep the tasks code independent from the notes code, which is being redesigned.

## Collaborators: 

- `NTTaskRepository`: holds one of my instances.
- `NTNoNoteDirectory`: my implementation while the todo part runs without notes.

## Public API and Key Messages

- `includesNoteNamed: aString`
- `noteTags`

Run `NTNoteDirectory class >> #scriptProtocol`.
"
Class {
	#name : 'NTNoteDirectory',
	#superclass : 'Object',
	#category : 'TheNoteTaker-Tasks-Notes',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Notes'
}

{ #category : 'script' }
NTNoteDirectory class >> scriptProtocol [
	"Show what the tasks ask the notes, using the implementation that knows no notes."

	<script>
	| directory |
	directory := NTNoNoteDirectory new.
	{
		('includesNoteNamed:' -> (directory includesNoteNamed: '2026-11-03_meeting.md')).
		('noteTags' -> directory noteTags) } inspect
]

{ #category : 'querying' }
NTNoteDirectory >> includesNoteNamed: aNoteFileName [
	"Answer whether a note with that file name exists, so an item's @note link can be checked."

	^ self subclassResponsibility
]

{ #category : 'querying' }
NTNoteDirectory >> noteTags [
	"Answer the names of the tags used on notes, to share one tag vocabulary with items."

	^ self subclassResponsibility
]
