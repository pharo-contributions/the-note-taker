Class {
	#name : 'NTISOFileNamerTest',
	#superclass : 'TestCase',
	#instVars : [
		'namer'
	],
	#category : 'TheNoteTaker-Tests-Support-Resources',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'running' }
NTISOFileNamerTest >> setUp [
	super setUp.

	namer := NTISOFileNamer new.
	namer date: (Date readFrom: '2024-11-02' readStream pattern: 'y-m-d').
]

{ #category : 'tests' }
NTISOFileNamerTest >> testDefaultName [

	self assert: namer defaultEmptyName equals: 'unnamed'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testDefaultNameSetDifferentlyDoesNotInfluenceNewNameBasedOn [

	self assert: namer defaultEmptyName equals: 'unnamed'.
	self
		assert: (namer newNameBasedOn: 'Toto')
		equals: '2024-11-02_Toto.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNameWithNameAlreadyTagged [

	| priorName |
	priorName := 'Bla' , namer separatorString , 'Unknown.md'.
	self assert: (namer newNameBasedOn: priorName) equals: '2024-11-02_' , priorName
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewName [

	self
		assert: (namer newNameBasedOn: 'Unknown.md')
		equals: '2024-11-02_Unknown.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewNameWithMultipleCleanedParts [

	| name |
	name := namer newNameBasedOn: 'Part1%_Part2\/_Part3'.
	self assert: name equals: '2024-11-02_Part1_Part2_Part3.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewNameWithMultipleParts [

	| name |
	name := namer newNameBasedOn: 'Part1_Part2_Part3'.
	self assert: name equals: '2024-11-02_Part1_Part2_Part3.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewNameWithNoExtension [

	| name |
	name := namer newNameBasedOn: 'Unknown'.
	self assert: name equals: '2024-11-02_Unknown.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewNameWithNoExtensionButPartsShouldStartWithDate [

	self
		assert: (namer newNameBasedOn: '2024-11-02_part12_part34_part56 78')
		equals: '2024-11-02_part12_part34_part5678.md'
]
