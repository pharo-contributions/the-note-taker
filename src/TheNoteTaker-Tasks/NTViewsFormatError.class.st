"
I am signaled by `NTItemViewSet class >> #fromText:` when the text of `views.md` cannot be read: invalid JSON, no ""views"" list, a view without name or with an unknown period, grouping or sorting. My message text says why.

See `NTViewsFormatError class >> #exampleError`.
"
Class {
	#name : 'NTViewsFormatError',
	#superclass : 'Error',
	#category : 'TheNoteTaker-Tasks-Views',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Views'
}

{ #category : 'examples' }
NTViewsFormatError class >> exampleError [

	<sampleInstance>
	^ self new
		  messageText: 'a view has no name';
		  yourself
]
