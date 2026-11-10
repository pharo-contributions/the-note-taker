"
I am the note directory used while the todo part runs without notes: I know no note and no tag.

## Responsibility:

- I answer that no note exists, so `@note(...)` links are stored and written back but not checked.
- I answer no note tags.
- I let `NTTaskRepository` work alone, in the app and in tests.

## Collaborators: 

- `NTTaskRepository`: uses me by default.

## Public API and Key Messages

- `includesNoteNamed: aString` answers false.
- `noteTags` answers an empty collection.

```
NTNoNoteDirectory new includesNoteNamed: '2026-11-03_meeting.md'  ""false""
```

See `NTNoNoteDirectory class >> #exampleEmpty`.
"
Class {
	#name : 'NTNoNoteDirectory',
	#superclass : 'NTNoteDirectory',
	#category : 'TheNoteTaker-Tasks-Notes',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Notes'
}

{ #category : 'examples' }
NTNoNoteDirectory class >> exampleEmpty [

	<sampleInstance>
	^ self new
]

{ #category : 'querying' }
NTNoNoteDirectory >> includesNoteNamed: aNoteFileName [

	^ false
]

{ #category : 'querying' }
NTNoNoteDirectory >> noteTags [

	^ #(  )
]
