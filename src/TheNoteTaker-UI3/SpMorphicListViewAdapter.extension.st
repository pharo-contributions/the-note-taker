Extension { #name : 'SpMorphicListViewAdapter' }

{ #category : '*TheNoteTaker-UI3' }
SpMorphicListViewAdapter >> buildWidget [
	| datasource |
	
	datasource := self newDataSource.
	datasource model: self model.
	
	widget := self newTableWith: datasource.
	"rows are presenters that can have different heights (see the data source).
	TheNoteTaker override until Spec includes pharo-spec/Spec#1982"
	widget beRowNotHomogeneous.
	"no search on list view (it has to be provided elsewhere)"
	widget disableFunction. 
	
	self presenter whenModelChangedDo: [ widget refresh ].
	self presenter whenSelectionChangedDo: [ self refreshWidgetSelection ].
	self presenter selection whenChangedDo: [ self refreshWidgetSelection ].

	self refreshWidgetSelection.
	self configureScrolling.

	^ widget
]
