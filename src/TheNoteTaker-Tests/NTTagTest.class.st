Class {
	#name : 'NTTagTest',
	#superclass : 'NTBasicTest',
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
NTTagTest >> testAccessTagId [
    | tag tagID |

    tag := NTTag new.
    tagID := tag tagId.

    self 
		assert: tagID isString
		description: 'Assuming tag ID is represented as a string'
]

{ #category : 'tests' }
NTTagTest >> testAccessTagName [
    | tag tagName |

    tagName := 'Sample Tag'.
    tag := NTTag newNamed: 'Tag name'.
    tag tagName: tagName.

    self assert: tag tagName equals: tagName.
]

{ #category : 'tests' }
NTTagTest >> testAccessTagNotes [
    | tag note1 note2 notes |

    tag := NTTag new.
    note1 := NTNoteObject new.
    note2 := NTNoteObject new.
    tag addNote: note1.
    tag addNote: note2.
    notes := tag notes.

    self assert: (notes includes: note1).
    self assert: (notes includes: note2).
]

{ #category : 'tests' }
NTTagTest >> testAddNoteToTag [

    | tag note |

    tag := NTTag new.
    note := NTNoteObject new.
    tag addNote: note.
    self assert: (tag notes includes: note).
]

{ #category : 'tests' }
NTTagTest >> testDeleteTag [
    | tag note |

    tag := NTTag new.
    note := NTNoteObject new.
    tag addNote: note.
    note removeTag: tag.

    self assertEmpty: tag notes.
]

{ #category : 'tests' }
NTTagTest >> testRemoveNoteFromTag [

    | tag note |

    tag := NTTag new.
    note := NTNoteObject new.
    tag addNote: note.
    tag removeNote: note.
    self deny: (tag notes includes: note).
]

{ #category : 'tests' }
NTTagTest >> testRenameTag [
    | tag newName |

    tag := NTTag new.
    newName := 'New Tag Name'.
    tag tagName: newName.

    self assert: tag tagName equals: newName.
]

{ #category : 'tests' }
NTTagTest >> testTagNote [

	| note noteTag |
	
	note := NTNoteObject named: self simplestNoteName.
	
	noteTag := NTTag newNamed: 'music'.

	self assertEmpty: note tags.

	note addTag: noteTag.

	self assert: note tags anyOne equals: noteTag
]
