Extension { #name : 'NTNullNoteObject' }

{ #category : '*TheNoteTaker-UI' }
NTNullNoteObject >> newFromPresenter: aNTSpNoteContentPresenter [ 

]

{ #category : '*TheNoteTaker-UI' }
NTNullNoteObject >> openFromPresenter: aNoteContentPresenter [

	aNoteContentPresenter contents: String empty
]
