Extension { #name : 'NTNoteObject' }

{ #category : '*TheNoteTaker-UI' }
NTNoteObject >> openFromPresenter: aNotePresenter [

	aNotePresenter editorPresenter openNote: self.
	contents := aNotePresenter editorPresenter textInputText 
]
