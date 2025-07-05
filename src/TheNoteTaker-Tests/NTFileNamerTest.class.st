Class {
	#name : 'NTFileNamerTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-Tests-Support-Resources',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'tests' }
NTFileNamerTest >> testDefaultName [

	self 
		assert: NTFileNamer new defaultEmptyName 
		equals: 'unnamed'
]

{ #category : 'tests' }
NTFileNamerTest >> testDefaultNameSetDifferently [

	| namer |
	namer := NTFileNamer new defaultEmptyName: 'Unknown'.
	self 
		assert: namer newName 
		equals: 'Unknown.md'
]

{ #category : 'tests' }
NTFileNamerTest >> testDefaultNameSetDifferentlyDoesNotInfluenceNewNameBasedOn [

	| namer |
	namer := NTFileNamer new defaultEmptyName: 'Unknown'.
	self 
		assert: (namer newNameBasedOn: 'Toto') 
		equals: 'Toto.md'
]

{ #category : 'tests' }
NTFileNamerTest >> testNameWithNameAlreadyTagged [

	| namer priorName name |
	namer := NTFileNamer new.
	priorName := 'Bla', namer separatorString, 'Unknown.md'.
	name := namer newNameBasedOn: priorName.	
	self assert: name equals: priorName
]

{ #category : 'tests' }
NTFileNamerTest >> testNewNameWithMultipleCleanedParts [

	| name |
	name := NTFileNamer new newNameBasedOn: 'Part1%_Part2\/_Part3'.
	self assert: name equals: 'Part1_Part2_Part3.md'
]

{ #category : 'tests' }
NTFileNamerTest >> testNewNameWithMultipleParts [

	| name |
	name := NTFileNamer new newNameBasedOn: 'Part1_Part2_Part3'.
	self assert: name equals: 'Part1_Part2_Part3.md'
]

{ #category : 'tests' }
NTFileNamerTest >> testNewNameWithNoExtension [

	| name |
	name := NTFileNamer new newNameBasedOn: 'Unknown'.
	self 
		assert: name 
		equals: 'Unknown.md'
]
