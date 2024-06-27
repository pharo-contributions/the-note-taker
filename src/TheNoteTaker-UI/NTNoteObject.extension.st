Extension { #name : 'NTNoteObject' }

{ #category : '*TheNoteTaker-UI' }
NTNoteObject >> openFromPresenter: aNotePresenter [

	aNotePresenter contentPresenter openNote: self
]
