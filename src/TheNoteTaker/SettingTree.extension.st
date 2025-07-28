Extension { #name : 'SettingTree' }

{ #category : '*TheNoteTaker' }
SettingTree >> nodeList [

	| builder |
	^ nodeList ifNil: [
			  builder := SettingTreeBuilder new.
			  self pragmasDo: [ :p |
					  (p methodClass name , '>>#' , p methodSelector) traceCr.
					  builder buildPragma: p ].

			  (builder nodeList collect: [ :n | n item name ]) traceCr.
			  nodeList := builder nodeList.
			  nodeList do: [ :n | n model: self ].
			  self checkForUnknownParent.
			  self checkForUnknownTarget.
			  self nodeList ]
]
